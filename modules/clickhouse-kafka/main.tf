# ClickHouse with Kafka Table Engine
# Using Altinity ClickHouse Operator + ClickHouseInstallation CRD

# Deploy ClickHouse Operator
resource "helm_release" "clickhouse_operator" {
  name             = "clickhouse-operator"
  namespace        = var.namespace
  create_namespace = var.create_namespace

  repository = "https://docs.altinity.com/clickhouse-operator/"
  chart      = "altinity-clickhouse-operator"
  version    = var.operator_version

  timeout = var.helm_timeout
  wait    = var.wait
}

# Deploy ClickHouse Installation via CRD (using kubectl provider)
resource "kubectl_manifest" "clickhouse_installation" {
  yaml_body = yamlencode({
    apiVersion = "clickhouse.altinity.com/v1"
    kind       = "ClickHouseInstallation"
    metadata = {
      name      = var.release_name
      namespace = var.namespace
    }
    spec = {
      configuration = {
        users = {
          "default/password" = ""
          "default/networks/ip" = "::/0"
        }
        clusters = [{
          name = var.release_name
          layout = {
            shardsCount   = var.shards
            replicasCount = var.replicas
          }
        }]
        settings = {
          # Kafka settings
          kafka_broker_list          = var.kafka_brokers
          kafka_topic_list           = join(",", var.kafka_topics)
          kafka_group_name           = var.kafka_consumer_group
          kafka_format               = var.kafka_format
          kafka_num_consumers        = var.kafka_num_consumers
          kafka_max_block_size       = var.kafka_max_block_size
          kafka_skip_broken_messages = var.kafka_skip_broken_messages
        }
      }
      defaults = {
        templates = {
          podTemplate = "clickhouse-pod"
        }
      }
      templates = {
        podTemplates = [{
          name = "clickhouse-pod"
          spec = {
            containers = [{
              name  = "clickhouse"
              image = "clickhouse/clickhouse-server:${var.clickhouse_version}"
              resources = {
                requests = {
                  cpu    = var.cpu_request
                  memory = var.memory_request
                }
                limits = {
                  cpu    = var.cpu_limit
                  memory = var.memory_limit
                }
              }
            }]
          }
        }]
      }
    }
  })

  depends_on = [helm_release.clickhouse_operator]
}

############################
# ClickHouse SQL Migrations
############################

locals {
  migrations_dir  = "${path.module}/migrations"
  migration_files = sort(fileset(local.migrations_dir, "*.sql"))

  # Map: filename -> file contents
  migrations_map = {
    for f in local.migration_files :
    f => file("${local.migrations_dir}/${f}")
  }

  # Stable "bundle" used for hashing: includes filename + content so renames also trigger
  migrations_bundle = join("\n--FILE--\n", [
    for f in local.migration_files :
    "${f}\n${local.migrations_map[f]}"
  ])

  # Include force_run in hash so bumping it triggers a new job
  migrations_hash = substr(sha256("${local.migrations_bundle}${var.migrations_force_run}"), 0, 8)

  # ClickHouse host for the deployed cluster
  clickhouse_host = "chi-${var.release_name}-${var.release_name}-0-0"
}

# ConfigMap containing SQL migrations
resource "kubectl_manifest" "clickhouse_migrations_configmap" {
  yaml_body = templatefile("${path.module}/templates/clickhouse-migrations-configmap.yaml", {
    namespace  = var.namespace
    name       = "${var.release_name}-migrations"
    migrations = local.migrations_map
  })

  depends_on = [kubectl_manifest.clickhouse_installation]
}

# Job to run migrations (re-created when migrations change via hash)
resource "kubectl_manifest" "clickhouse_run_migrations_job" {
  yaml_body = templatefile("${path.module}/templates/clickhouse-run-migrations-job.yaml", {
    namespace       = var.namespace
    job_name        = "${var.release_name}-migrations-${local.migrations_hash}"
    configmap_name  = "${var.release_name}-migrations"
    clickhouse_host = local.clickhouse_host
    clickhouse_user = var.clickhouse_user
    clickhouse_pass = var.clickhouse_password
    service_account = "default"
  })

  depends_on = [
    kubectl_manifest.clickhouse_installation,
    kubectl_manifest.clickhouse_migrations_configmap,
  ]
}
