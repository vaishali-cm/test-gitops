# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "namespace" {
  description = "Kubernetes namespace where Flink operator will be deployed"
  type        = string
}

# -----------------------------------------------------------------------------
# Optional Variables
# -----------------------------------------------------------------------------

variable "release_name" {
  description = "Helm release name for the Flink operator"
  type        = string
  default     = "flink-operator"
}

variable "create_namespace" {
  description = "Create the namespace if it doesn't exist"
  type        = bool
  default     = true
}

variable "operator_version" {
  description = "Version of the Flink Kubernetes Operator"
  type        = string
  default     = "1.8.0"
}

variable "operator_image_tag" {
  description = "Docker image tag for the Flink operator"
  type        = string
  default     = "1.8.0"
}

variable "operator_replicas" {
  description = "Number of operator replicas"
  type        = number
  default     = 1
}

variable "webhook_enabled" {
  description = "Enable webhook for the operator"
  type        = bool
  default     = true
}

variable "metrics_enabled" {
  description = "Enable metrics collection"
  type        = bool
  default     = true
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

variable "helm_timeout" {
  description = "Timeout for Helm operations in seconds"
  type        = number
  default     = 600
}

variable "additional_set_values" {
  description = "Additional values to set via Helm"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Flink Configuration Variables
# -----------------------------------------------------------------------------

variable "create_default_config" {
  description = "Create a default Flink configuration ConfigMap"
  type        = bool
  default     = false
}

variable "taskmanager_memory" {
  description = "TaskManager memory configuration"
  type        = string
  default     = "2048m"
}

variable "jobmanager_memory" {
  description = "JobManager memory configuration"
  type        = string
  default     = "1024m"
}

variable "parallelism_default" {
  description = "Default parallelism for Flink jobs"
  type        = number
  default     = 2
}

variable "checkpoint_interval" {
  description = "Checkpoint interval in milliseconds"
  type        = number
  default     = 60000
}

variable "state_backend" {
  description = "State backend type (hashmap, rocksdb)"
  type        = string
  default     = "rocksdb"
}

variable "additional_flink_config" {
  description = "Additional Flink configuration options"
  type        = map(string)
  default     = {}
}
