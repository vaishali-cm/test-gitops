output "release_name" {
  description = "Helm release name"
  value       = helm_release.flink_operator.name
}

output "namespace" {
  description = "Namespace where Flink operator is deployed"
  value       = helm_release.flink_operator.namespace
}

output "chart_version" {
  description = "Version of the deployed Flink operator chart"
  value       = helm_release.flink_operator.version
}

output "status" {
  description = "Status of the Helm release"
  value       = helm_release.flink_operator.status
}

output "job_service_account_name" {
  description = "Name of the ServiceAccount for Flink jobs"
  value       = var.create_job_service_account ? kubernetes_service_account.flink_job_sa[0].metadata[0].name : null
}
