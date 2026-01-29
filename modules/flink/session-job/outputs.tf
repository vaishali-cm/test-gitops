output "name" {
  description = "Name of the FlinkSessionJob"
  value       = kubernetes_manifest.flink_session_job.manifest.metadata.name
}

output "namespace" {
  description = "Namespace of the FlinkSessionJob"
  value       = kubernetes_manifest.flink_session_job.manifest.metadata.namespace
}

output "deployment_name" {
  description = "Name of the target FlinkDeployment (Session cluster)"
  value       = var.deployment_name
}

output "job_jar_uri" {
  description = "URI of the job JAR"
  value       = var.job_jar_uri
}

output "job_parallelism" {
  description = "Job parallelism"
  value       = var.job_parallelism
}

output "job_state" {
  description = "Current desired job state"
  value       = var.job_state
}
