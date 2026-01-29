# -----------------------------------------------------------------------------
# Flink Outputs
# -----------------------------------------------------------------------------

output "flink_operator_namespace" {
  description = "Namespace where Flink operator is deployed"
  value       = module.flink_operator.namespace
}

output "flink_operator_release" {
  description = "Flink operator Helm release name"
  value       = module.flink_operator.release_name
}

output "flink_session_name" {
  description = "Flink session cluster name"
  value       = module.flink_session.name
}

output "flink_session_service" {
  description = "Flink session REST service name"
  value       = module.flink_session.service_name
}

# -----------------------------------------------------------------------------
# ClickHouse Outputs
# -----------------------------------------------------------------------------

output "clickhouse_namespace" {
  description = "Namespace where ClickHouse is deployed"
  value       = module.clickhouse.cluster_namespace
}

output "clickhouse_cluster_name" {
  description = "ClickHouse cluster name"
  value       = module.clickhouse.cluster_name
}

output "clickhouse_service" {
  description = "ClickHouse service name"
  value       = module.clickhouse.cluster_service
}
