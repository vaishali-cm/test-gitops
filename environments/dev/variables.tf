# -----------------------------------------------------------------------------
# Kubernetes Configuration
# -----------------------------------------------------------------------------

variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "kubeconfig_context" {
  description = "Kubernetes context to use"
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Version Configuration
# -----------------------------------------------------------------------------

variable "flink_operator_version" {
  description = "Version of the Flink Kubernetes Operator Helm chart"
  type        = string
  default     = "1.8.0"
}

variable "flink_version" {
  description = "Flink version for deployments (e.g., v1_18)"
  type        = string
  default     = "v1_18"
}

variable "clickhouse_operator_version" {
  description = "Version of the ClickHouse Operator"
  type        = string
  default     = "0.23.0"
}

variable "clickhouse_version" {
  description = "ClickHouse server version"
  type        = string
  default     = "24.3"
}

# -----------------------------------------------------------------------------
# Infrastructure Configuration
# -----------------------------------------------------------------------------

variable "storage_class" {
  description = "Kubernetes storage class to use"
  type        = string
  default     = "standard"
}

variable "team_name" {
  description = "Team name for resource labeling"
  type        = string
  default     = "platform"
}
