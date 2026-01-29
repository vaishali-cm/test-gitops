output "release_name" {
  description = "Helm release name"
  value       = helm_release.flink_operator.name
}

output "namespace" {
  description = "Namespace where Flink operator is deployed"
  value       = helm_release.flink_operator.namespace
}

output "operator_version" {
  description = "Version of the deployed Flink operator"
  value       = helm_release.flink_operator.version
}

output "chart" {
  description = "Chart name"
  value       = helm_release.flink_operator.chart
}

output "status" {
  description = "Status of the Helm release"
  value       = helm_release.flink_operator.status
}
