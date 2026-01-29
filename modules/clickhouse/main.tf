# ClickHouse Kubernetes Module
# Deploys ClickHouse on an existing Kubernetes cluster using the ClickHouse Operator

# Deploy ClickHouse Operator first
resource "helm_release" "clickhouse_operator" {
  name             = "${var.release_name}-operator"
  namespace        = var.operator_namespace
  create_namespace = var.create_namespace

  repository = "https://docs.altinity.com/clickhouse-operator/"
  chart      = "altinity-clickhouse-operator"
  version    = var.operator_version

  values = [
    templatefile("${path.module}/templates/operator-values.yaml.tpl", {
      replicas        = var.operator_replicas
      metrics_enabled = var.metrics_enabled
    })
  ]

  timeout = var.helm_timeout
}

# Deploy ClickHouse cluster
resource "kubernetes_manifest" "clickhouse_installation" {
  count = var.deploy_cluster ? 1 : 0

  manifest = yamldecode(templatefile("${path.module}/templates/clickhouse-cluster.yaml.tpl", {
    name                  = var.cluster_name
    namespace             = var.namespace
    replicas              = var.cluster_replicas
    shards                = var.cluster_shards
    clickhouse_version    = var.clickhouse_version
    storage_class         = var.storage_class
    storage_size          = var.storage_size
    cpu_requests          = var.resource_requests.cpu
    memory_requests       = var.resource_requests.memory
    cpu_limits            = var.resource_limits.cpu
    memory_limits         = var.resource_limits.memory
    zookeeper_enabled     = var.zookeeper_enabled
    zookeeper_namespace   = var.zookeeper_namespace
    zookeeper_service     = var.zookeeper_service
    additional_settings   = var.additional_clickhouse_settings
    labels                = var.labels
  }))

  depends_on = [helm_release.clickhouse_operator]
}

# Optional: Create ClickHouse users secret
resource "kubernetes_secret" "clickhouse_users" {
  count = var.create_users_secret ? 1 : 0

  metadata {
    name      = "${var.cluster_name}-users"
    namespace = var.namespace
    labels    = var.labels
  }

  data = {
    for user, config in var.clickhouse_users : user => config.password
  }

  type = "Opaque"

  depends_on = [helm_release.clickhouse_operator]
}
