# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "name" {
  description = "Name of the FlinkDeployment"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for the deployment"
  type        = string
}

# -----------------------------------------------------------------------------
# Deployment Mode
# -----------------------------------------------------------------------------

variable "mode" {
  description = "Deployment mode: Application or Session"
  type        = string
  default     = "Application"

  validation {
    condition     = contains(["Application", "Session"], var.mode)
    error_message = "Mode must be either 'Application' or 'Session'."
  }
}

# -----------------------------------------------------------------------------
# Flink Configuration
# -----------------------------------------------------------------------------

variable "flink_version" {
  description = "Flink version to use"
  type        = string
  default     = "v1_18"
}

variable "image" {
  description = "Custom Flink Docker image (defaults to official image)"
  type        = string
  default     = null
}

variable "service_account" {
  description = "ServiceAccount name for the deployment"
  type        = string
  default     = "flink"
}

variable "task_slots" {
  description = "Number of task slots per TaskManager"
  type        = number
  default     = 2
}

variable "state_backend" {
  description = "State backend type: hashmap or rocksdb"
  type        = string
  default     = "rocksdb"
}

variable "checkpoint_storage_path" {
  description = "Path for checkpoint storage (e.g., s3://bucket/checkpoints)"
  type        = string
  default     = null
}

variable "savepoint_storage_path" {
  description = "Path for savepoint storage (e.g., s3://bucket/savepoints)"
  type        = string
  default     = null
}

variable "flink_configuration" {
  description = "Additional Flink configuration options"
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# High Availability
# -----------------------------------------------------------------------------

variable "ha_enabled" {
  description = "Enable high availability mode"
  type        = bool
  default     = false
}

variable "ha_storage_path" {
  description = "Storage path for HA metadata (e.g., s3://bucket/ha)"
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# JobManager Configuration
# -----------------------------------------------------------------------------

variable "jobmanager_cpu" {
  description = "CPU allocation for JobManager"
  type        = number
  default     = 1
}

variable "jobmanager_memory" {
  description = "Memory allocation for JobManager"
  type        = string
  default     = "2048m"
}

variable "jobmanager_replicas" {
  description = "Number of JobManager replicas (for HA)"
  type        = number
  default     = 1
}

variable "jobmanager_pod_template" {
  description = "Custom pod template for JobManager"
  type        = any
  default     = null
}

# -----------------------------------------------------------------------------
# TaskManager Configuration
# -----------------------------------------------------------------------------

variable "taskmanager_cpu" {
  description = "CPU allocation for TaskManager"
  type        = number
  default     = 1
}

variable "taskmanager_memory" {
  description = "Memory allocation for TaskManager"
  type        = string
  default     = "2048m"
}

variable "taskmanager_replicas" {
  description = "Number of TaskManager replicas"
  type        = number
  default     = 2
}

variable "taskmanager_pod_template" {
  description = "Custom pod template for TaskManager"
  type        = any
  default     = null
}

# -----------------------------------------------------------------------------
# Job Configuration (Application Mode Only)
# -----------------------------------------------------------------------------

variable "job_jar_uri" {
  description = "URI of the job JAR file (required for Application mode)"
  type        = string
  default     = null
}

variable "job_entry_class" {
  description = "Entry class for the Flink job"
  type        = string
  default     = null
}

variable "job_args" {
  description = "Arguments to pass to the Flink job"
  type        = list(string)
  default     = []
}

variable "job_parallelism" {
  description = "Parallelism for the Flink job"
  type        = number
  default     = 2
}

variable "job_upgrade_mode" {
  description = "Upgrade mode: stateless, savepoint, or last-state"
  type        = string
  default     = "stateless"

  validation {
    condition     = contains(["stateless", "savepoint", "last-state"], var.job_upgrade_mode)
    error_message = "Upgrade mode must be 'stateless', 'savepoint', or 'last-state'."
  }
}

variable "job_state" {
  description = "Desired job state: running or suspended"
  type        = string
  default     = "running"

  validation {
    condition     = contains(["running", "suspended"], var.job_state)
    error_message = "Job state must be 'running' or 'suspended'."
  }
}

variable "job_savepoint_path" {
  description = "Initial savepoint path to restore from"
  type        = string
  default     = null
}

variable "job_allow_non_restored_state" {
  description = "Allow job to start with non-restored state"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Ingress Configuration
# -----------------------------------------------------------------------------

variable "ingress_enabled" {
  description = "Enable ingress for the Flink UI"
  type        = bool
  default     = false
}

variable "ingress_host" {
  description = "Ingress host template"
  type        = string
  default     = "flink.example.com"
}

variable "ingress_class" {
  description = "Ingress class name"
  type        = string
  default     = "nginx"
}

variable "ingress_annotations" {
  description = "Annotations for the ingress"
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Pod Template
# -----------------------------------------------------------------------------

variable "pod_template" {
  description = "Custom pod template for all Flink pods"
  type        = any
  default     = null
}

# -----------------------------------------------------------------------------
# Logging
# -----------------------------------------------------------------------------

variable "log_configuration" {
  description = "Custom log configuration"
  type        = map(string)
  default     = null
}

# -----------------------------------------------------------------------------
# Metadata
# -----------------------------------------------------------------------------

variable "labels" {
  description = "Labels to apply to the FlinkDeployment"
  type        = map(string)
  default     = {}
}

variable "annotations" {
  description = "Annotations to apply to the FlinkDeployment"
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Terraform Configuration
# -----------------------------------------------------------------------------

variable "force_conflicts" {
  description = "Force field manager conflicts"
  type        = bool
  default     = true
}

variable "timeout_create" {
  description = "Timeout for create operations"
  type        = string
  default     = "10m"
}

variable "timeout_update" {
  description = "Timeout for update operations"
  type        = string
  default     = "10m"
}

variable "timeout_delete" {
  description = "Timeout for delete operations"
  type        = string
  default     = "10m"
}
