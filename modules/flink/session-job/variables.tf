# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "name" {
  description = "Name of the FlinkSessionJob"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for the session job"
  type        = string
}

variable "deployment_name" {
  description = "Name of the FlinkDeployment (Session cluster) to submit the job to"
  type        = string
}

variable "job_jar_uri" {
  description = "URI of the job JAR file (can be local path or remote URL)"
  type        = string
}

# -----------------------------------------------------------------------------
# Job Configuration
# -----------------------------------------------------------------------------

variable "job_entry_class" {
  description = "Fully qualified entry class for the Flink job"
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
# Restart Configuration
# -----------------------------------------------------------------------------

variable "restart_nonce" {
  description = "Nonce to trigger job restart (change this value to restart)"
  type        = number
  default     = null
}

# -----------------------------------------------------------------------------
# Flink Configuration Overrides
# -----------------------------------------------------------------------------

variable "flink_configuration" {
  description = "Flink configuration overrides for this specific job"
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Metadata
# -----------------------------------------------------------------------------

variable "labels" {
  description = "Labels to apply to the FlinkSessionJob"
  type        = map(string)
  default     = {}
}

variable "annotations" {
  description = "Annotations to apply to the FlinkSessionJob"
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
