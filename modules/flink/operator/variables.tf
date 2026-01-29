# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "namespace" {
  description = "Kubernetes namespace where Flink operator will be deployed"
  type        = string
}

# -----------------------------------------------------------------------------
# Helm Release Configuration
# -----------------------------------------------------------------------------

variable "release_name" {
  description = "Helm release name for the Flink operator"
  type        = string
  default     = "flink-kubernetes-operator"
}

variable "create_namespace" {
  description = "Create the namespace if it doesn't exist"
  type        = bool
  default     = true
}

variable "chart_version" {
  description = "Version of the Flink Kubernetes Operator Helm chart"
  type        = string
  default     = "1.8.0"
}

variable "values_yaml" {
  description = "Custom values.yaml content (overrides template)"
  type        = string
  default     = null
}

variable "helm_timeout" {
  description = "Timeout for Helm operations in seconds"
  type        = number
  default     = 600
}

variable "wait" {
  description = "Wait for all resources to be ready"
  type        = bool
  default     = true
}

variable "wait_for_jobs" {
  description = "Wait for all Jobs to be complete"
  type        = bool
  default     = false
}

variable "atomic" {
  description = "If true, installation will be atomic"
  type        = bool
  default     = false
}

variable "cleanup_on_fail" {
  description = "Allow deletion of new resources on failed update"
  type        = bool
  default     = true
}

variable "force_update" {
  description = "Force resource update through delete/recreate if needed"
  type        = bool
  default     = false
}

variable "recreate_pods" {
  description = "Recreate pods on update"
  type        = bool
  default     = false
}

variable "additional_set_values" {
  description = "Additional values to set via Helm"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "additional_set_sensitive_values" {
  description = "Additional sensitive values to set via Helm"
  type = list(object({
    name  = string
    value = string
  }))
  default   = []
  sensitive = true
}

# -----------------------------------------------------------------------------
# Operator Configuration
# -----------------------------------------------------------------------------

variable "operator_replicas" {
  description = "Number of operator replicas"
  type        = number
  default     = 1
}

variable "image_repository" {
  description = "Docker image repository for the Flink operator"
  type        = string
  default     = "ghcr.io/apache/flink-kubernetes-operator"
}

variable "image_tag" {
  description = "Docker image tag for the Flink operator"
  type        = string
  default     = ""
}

variable "webhook_enabled" {
  description = "Enable admission webhook for the operator"
  type        = bool
  default     = true
}

variable "metrics_enabled" {
  description = "Enable metrics collection"
  type        = bool
  default     = true
}

variable "watch_namespaces" {
  description = "List of namespaces to watch (empty for all namespaces)"
  type        = list(string)
  default     = []
}

variable "log_level" {
  description = "Operator log level"
  type        = string
  default     = "INFO"
}

variable "flink_default_version" {
  description = "Default Flink version for deployments"
  type        = string
  default     = "1.18"
}

variable "resource_requests" {
  description = "Resource requests for the operator"
  type = object({
    cpu    = string
    memory = string
  })
  default = {
    cpu    = "100m"
    memory = "256Mi"
  }
}

variable "resource_limits" {
  description = "Resource limits for the operator"
  type = object({
    cpu    = string
    memory = string
  })
  default = {
    cpu    = "500m"
    memory = "512Mi"
  }
}

# -----------------------------------------------------------------------------
# Service Account Configuration
# -----------------------------------------------------------------------------

variable "create_job_service_account" {
  description = "Create a ServiceAccount for Flink jobs"
  type        = bool
  default     = true
}

variable "job_service_account_name" {
  description = "Name of the ServiceAccount for Flink jobs"
  type        = string
  default     = "flink"
}

variable "job_service_account_annotations" {
  description = "Annotations for the job ServiceAccount (e.g., for IRSA)"
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Labels
# -----------------------------------------------------------------------------

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}
