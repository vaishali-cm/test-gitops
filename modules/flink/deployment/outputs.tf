output "name" {
  description = "Name of the FlinkDeployment"
  value       = kubernetes_manifest.flink_deployment.manifest.metadata.name
}

output "namespace" {
  description = "Namespace of the FlinkDeployment"
  value       = kubernetes_manifest.flink_deployment.manifest.metadata.namespace
}

output "mode" {
  description = "Deployment mode (Application or Session)"
  value       = var.mode
}

output "flink_version" {
  description = "Flink version"
  value       = var.flink_version
}

output "jobmanager_replicas" {
  description = "Number of JobManager replicas"
  value       = var.jobmanager_replicas
}

output "taskmanager_replicas" {
  description = "Number of TaskManager replicas"
  value       = var.taskmanager_replicas
}

output "service_name" {
  description = "Service name for accessing the Flink REST API"
  value       = "${var.name}-rest"
}
