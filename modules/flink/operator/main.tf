# Flink Kubernetes Operator Module
# Deploys the Apache Flink Kubernetes Operator via Helm

resource "helm_release" "flink_operator" {
  name             = var.release_name
  namespace        = var.namespace
  create_namespace = var.create_namespace

  repository = "https://downloads.apache.org/flink/flink-kubernetes-operator-${var.chart_version}/"
  chart      = "flink-kubernetes-operator"
  version    = var.chart_version

  values = var.values_yaml != null ? [var.values_yaml] : [
    templatefile("${path.module}/templates/values.yaml.tpl", {
      replicas              = var.operator_replicas
      image_repository      = var.image_repository
      image_tag             = var.image_tag
      webhook_enabled       = var.webhook_enabled
      metrics_enabled       = var.metrics_enabled
      resource_requests     = var.resource_requests
      resource_limits       = var.resource_limits
      watch_namespaces      = var.watch_namespaces
      log_level             = var.log_level
      flink_default_version = var.flink_default_version
    })
  ]

  dynamic "set" {
    for_each = var.additional_set_values
    content {
      name  = set.value.name
      value = set.value.value
    }
  }

  dynamic "set_sensitive" {
    for_each = var.additional_set_sensitive_values
    content {
      name  = set_sensitive.value.name
      value = set_sensitive.value.value
    }
  }

  timeout          = var.helm_timeout
  wait             = var.wait
  wait_for_jobs    = var.wait_for_jobs
  atomic           = var.atomic
  cleanup_on_fail  = var.cleanup_on_fail
  force_update     = var.force_update
  recreate_pods    = var.recreate_pods
}

# ServiceAccount for Flink jobs (if needed for RBAC)
resource "kubernetes_service_account" "flink_job_sa" {
  count = var.create_job_service_account ? 1 : 0

  metadata {
    name      = var.job_service_account_name
    namespace = var.namespace
    labels    = var.labels

    annotations = var.job_service_account_annotations
  }

  depends_on = [helm_release.flink_operator]
}

# ClusterRoleBinding for Flink jobs
resource "kubernetes_cluster_role_binding" "flink_job_crb" {
  count = var.create_job_service_account ? 1 : 0

  metadata {
    name   = "${var.job_service_account_name}-binding"
    labels = var.labels
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "edit"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.flink_job_sa[0].metadata[0].name
    namespace = var.namespace
  }

  depends_on = [kubernetes_service_account.flink_job_sa]
}
