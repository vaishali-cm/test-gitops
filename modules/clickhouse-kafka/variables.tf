# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "kafka_brokers" {
  description = "Kafka broker addresses (comma-separated)"
  type        = string
}

# -----------------------------------------------------------------------------
# Helm Configuration
# -----------------------------------------------------------------------------

variable "release_name" {
  description = "Helm release name"
  type        = string
  default     = "clickhouse"
}

variable "create_namespace" {
  description = "Create namespace if it doesn't exist"
  type        = bool
  default     = true
}

variable "operator_version" {
  description = "Altinity ClickHouse Operator chart version"
  type        = string
  default     = "0.24.0"
}

variable "clickhouse_version" {
  description = "ClickHouse server image tag"
  type        = string
  default     = "24.8"
}

variable "clickhouse_user" {
  description = "ClickHouse user for migrations"
  type        = string
  default     = "default"
}

variable "clickhouse_password" {
  description = "ClickHouse password for migrations"
  type        = string
  default     = ""
  sensitive   = true
}

variable "migrations_force_run" {
  description = "Bump this value to force re-run migrations job (e.g. 'v2', 'v3')"
  type        = string
  default     = ""
}

variable "helm_timeout" {
  description = "Helm timeout in seconds"
  type        = number
  default     = 600
}

variable "wait" {
  description = "Wait for resources to be ready"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# ClickHouse Configuration
# -----------------------------------------------------------------------------

variable "shards" {
  description = "Number of shards"
  type        = number
  default     = 1
}

variable "replicas" {
  description = "Number of replicas per shard"
  type        = number
  default     = 1
}

# -----------------------------------------------------------------------------
# Kafka Table Engine Configuration
# -----------------------------------------------------------------------------

variable "kafka_topics" {
  description = "List of Kafka topics"
  type        = list(string)
  default     = []
}

variable "kafka_metric_topic" {
  description = "Kafka topic for metric_updates table"
  type        = string
  default     = "metric-updates"
}

variable "kafka_consumer_group" {
  description = "Kafka consumer group name"
  type        = string
  default     = "clickhouse"
}

variable "kafka_format" {
  description = "Data format (JSONEachRow, CSV, etc.)"
  type        = string
  default     = "JSONEachRow"
}

variable "kafka_num_consumers" {
  description = "Number of consumers per table"
  type        = number
  default     = 1
}

variable "kafka_max_block_size" {
  description = "Maximum block size for polling"
  type        = number
  default     = 65536
}

variable "kafka_skip_broken_messages" {
  description = "Number of broken messages to skip"
  type        = number
  default     = 0
}

variable "kafka_commit_every_batch" {
  description = "Commit after every batch"
  type        = bool
  default     = false
}

variable "kafka_max_wait_ms" {
  description = "Max wait time in ms"
  type        = number
  default     = 5000
}

variable "kafka_poll_timeout_ms" {
  description = "Poll timeout in ms"
  type        = number
  default     = 500
}

variable "kafka_flush_interval_ms" {
  description = "Flush interval in ms"
  type        = number
  default     = 7500
}

# -----------------------------------------------------------------------------
# Kafka Security (Optional)
# -----------------------------------------------------------------------------

variable "kafka_security_protocol" {
  description = "Security protocol (PLAINTEXT, SSL, SASL_PLAINTEXT, SASL_SSL)"
  type        = string
  default     = ""
}

variable "kafka_sasl_mechanism" {
  description = "SASL mechanism (PLAIN, SCRAM-SHA-256, SCRAM-SHA-512)"
  type        = string
  default     = ""
}

variable "kafka_sasl_username" {
  description = "SASL username"
  type        = string
  default     = ""
  sensitive   = true
}

variable "kafka_sasl_password" {
  description = "SASL password"
  type        = string
  default     = ""
  sensitive   = true
}

# -----------------------------------------------------------------------------
# Resources
# -----------------------------------------------------------------------------

variable "cpu_request" {
  description = "CPU request"
  type        = string
  default     = "500m"
}

variable "memory_request" {
  description = "Memory request"
  type        = string
  default     = "2Gi"
}

variable "cpu_limit" {
  description = "CPU limit"
  type        = string
  default     = "2"
}

variable "memory_limit" {
  description = "Memory limit"
  type        = string
  default     = "4Gi"
}

# -----------------------------------------------------------------------------
# Storage
# -----------------------------------------------------------------------------

variable "persistence_enabled" {
  description = "Enable persistent storage"
  type        = bool
  default     = true
}

variable "storage_class" {
  description = "Storage class"
  type        = string
  default     = "standard"
}

variable "storage_size" {
  description = "Storage size"
  type        = string
  default     = "50Gi"
}

# -----------------------------------------------------------------------------
# ZooKeeper
# -----------------------------------------------------------------------------

variable "zookeeper_enabled" {
  description = "Deploy ZooKeeper with the chart"
  type        = bool
  default     = false
}

variable "external_zookeeper_servers" {
  description = "External ZooKeeper servers"
  type        = list(string)
  default     = []
}

