output "operator_release_name" {
  description = "Helm release name for the ClickHouse operator"
  value       = helm_release.clickhouse_operator.name
}

output "operator_namespace" {
  description = "Namespace where ClickHouse operator is deployed"
  value       = helm_release.clickhouse_operator.namespace
}

output "operator_version" {
  description = "Version of the deployed ClickHouse operator"
  value       = helm_release.clickhouse_operator.version
}

output "cluster_name" {
  description = "Name of the ClickHouse cluster"
  value       = var.deploy_cluster ? var.cluster_name : null
}

output "cluster_namespace" {
  description = "Namespace where ClickHouse cluster is deployed"
  value       = var.deploy_cluster ? var.namespace : null
}

output "cluster_service" {
  description = "Service name for the ClickHouse cluster"
  value       = var.deploy_cluster ? "clickhouse-${var.cluster_name}" : null
}
