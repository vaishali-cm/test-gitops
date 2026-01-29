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
# Flink Configuration
# -----------------------------------------------------------------------------

variable "flink_jobmanager_cpu" {
  description = "CPU allocation for Flink JobManager"
  type        = number
  default     = 2
}

variable "flink_jobmanager_memory" {
  description = "Memory allocation for Flink JobManager"
  type        = string
  default     = "4096m"
}

variable "flink_taskmanager_cpu" {
  description = "CPU allocation for Flink TaskManager"
  type        = number
  default     = 4
}

variable "flink_taskmanager_memory" {
  description = "Memory allocation for Flink TaskManager"
  type        = string
  default     = "8192m"
}

variable "flink_taskmanager_replicas" {
  description = "Number of Flink TaskManager replicas"
  type        = number
  default     = 6
}

variable "flink_task_slots" {
  description = "Number of task slots per TaskManager"
  type        = number
  default     = 4
}

variable "flink_checkpoint_path" {
  description = "Path for Flink checkpoints (e.g., s3://bucket/checkpoints)"
  type        = string
}

variable "flink_savepoint_path" {
  description = "Path for Flink savepoints (e.g., s3://bucket/savepoints)"
  type        = string
}

variable "flink_ha_path" {
  description = "Path for Flink HA metadata (e.g., s3://bucket/ha)"
  type        = string
}

variable "flink_service_account_annotations" {
  description = "Annotations for Flink service account (e.g., for IRSA)"
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# ClickHouse Configuration
# -----------------------------------------------------------------------------

variable "clickhouse_replicas" {
  description = "Number of ClickHouse replicas per shard"
  type        = number
  default     = 3
}

variable "clickhouse_shards" {
  description = "Number of ClickHouse shards"
  type        = number
  default     = 2
}

variable "clickhouse_storage_size" {
  description = "Storage size for ClickHouse"
  type        = string
  default     = "500Gi"
}

variable "clickhouse_cpu_request" {
  description = "CPU request for ClickHouse"
  type        = string
  default     = "2"
}

variable "clickhouse_memory_request" {
  description = "Memory request for ClickHouse"
  type        = string
  default     = "8Gi"
}

variable "clickhouse_cpu_limit" {
  description = "CPU limit for ClickHouse"
  type        = string
  default     = "8"
}

variable "clickhouse_memory_limit" {
  description = "Memory limit for ClickHouse"
  type        = string
  default     = "32Gi"
}

# -----------------------------------------------------------------------------
# Infrastructure Configuration
# -----------------------------------------------------------------------------

variable "storage_class" {
  description = "Kubernetes storage class to use"
  type        = string
  default     = "gp3"
}

variable "team_name" {
  description = "Team name for resource labeling"
  type        = string
  default     = "platform"
}

# -----------------------------------------------------------------------------
# ZooKeeper Configuration
# -----------------------------------------------------------------------------

variable "zookeeper_namespace" {
  description = "Namespace where ZooKeeper is deployed"
  type        = string
  default     = "zookeeper"
}

variable "zookeeper_service" {
  description = "ZooKeeper service name"
  type        = string
  default     = "zookeeper"
}
