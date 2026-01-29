# Flink Kubernetes Operator Module
# Deploys Apache Flink on an existing Kubernetes cluster

resource "helm_release" "flink_operator" {
  name             = var.release_name
  namespace        = var.namespace
  create_namespace = var.create_namespace

  repository = "https://downloads.apache.org/flink/flink-kubernetes-operator-${var.operator_version}/"
  chart      = "flink-kubernetes-operator"
  version    = var.operator_version

  values = [
    templatefile("${path.module}/templates/values.yaml.tpl", {
      replicas           = var.operator_replicas
      image_tag          = var.operator_image_tag
      webhook_enabled    = var.webhook_enabled
      metrics_enabled    = var.metrics_enabled
      resource_requests  = var.resource_requests
      resource_limits    = var.resource_limits
    })
  ]

  dynamic "set" {
    for_each = var.additional_set_values
    content {
      name  = set.value.name
      value = set.value.value
    }
  }

  timeout = var.helm_timeout
}

# Optional: Create default Flink configuration ConfigMap
resource "kubernetes_config_map" "flink_config" {
  count = var.create_default_config ? 1 : 0

  metadata {
    name      = "${var.release_name}-config"
    namespace = var.namespace
    labels    = var.labels
  }

  data = {
    "flink-conf.yaml" = templatefile("${path.module}/templates/flink-conf.yaml.tpl", {
      taskmanager_memory     = var.taskmanager_memory
      jobmanager_memory      = var.jobmanager_memory
      parallelism_default    = var.parallelism_default
      checkpoint_interval    = var.checkpoint_interval
      state_backend          = var.state_backend
      additional_flink_config = var.additional_flink_config
    })
  }

  depends_on = [helm_release.flink_operator]
}
