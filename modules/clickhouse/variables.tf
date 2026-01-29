# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "namespace" {
  description = "Kubernetes namespace where ClickHouse cluster will be deployed"
  type        = string
}

# -----------------------------------------------------------------------------
# Operator Variables
# -----------------------------------------------------------------------------

variable "release_name" {
  description = "Helm release name for the ClickHouse operator"
  type        = string
  default     = "clickhouse"
}

variable "operator_namespace" {
  description = "Namespace for the ClickHouse operator"
  type        = string
  default     = "clickhouse-operator"
}

variable "create_namespace" {
  description = "Create the namespace if it doesn't exist"
  type        = bool
  default     = true
}

variable "operator_version" {
  description = "Version of the Altinity ClickHouse Operator Helm chart"
  type        = string
  default     = "0.23.0"
}

variable "operator_replicas" {
  description = "Number of operator replicas"
  type        = number
  default     = 1
}

variable "helm_timeout" {
  description = "Timeout for Helm operations in seconds"
  type        = number
  default     = 600
}

variable "metrics_enabled" {
  description = "Enable metrics collection for the operator"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# ClickHouse Cluster Variables
# -----------------------------------------------------------------------------

variable "deploy_cluster" {
  description = "Deploy a ClickHouse cluster (set to false if only installing operator)"
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "Name of the ClickHouse cluster"
  type        = string
  default     = "clickhouse-cluster"
}

variable "cluster_replicas" {
  description = "Number of replicas per shard"
  type        = number
  default     = 2
}

variable "cluster_shards" {
  description = "Number of shards in the cluster"
  type        = number
  default     = 1
}

variable "clickhouse_version" {
  description = "ClickHouse server version"
  type        = string
  default     = "24.3"
}

variable "storage_class" {
  description = "Storage class for persistent volumes"
  type        = string
  default     = "standard"
}

variable "storage_size" {
  description = "Size of persistent volume for each replica"
  type        = string
  default     = "100Gi"
}

variable "resource_requests" {
  description = "Resource requests for ClickHouse pods"
  type = object({
    cpu    = string
    memory = string
  })
  default = {
    cpu    = "500m"
    memory = "2Gi"
  }
}

variable "resource_limits" {
  description = "Resource limits for ClickHouse pods"
  type = object({
    cpu    = string
    memory = string
  })
  default = {
    cpu    = "2"
    memory = "4Gi"
  }
}

# -----------------------------------------------------------------------------
# ZooKeeper Variables
# -----------------------------------------------------------------------------

variable "zookeeper_enabled" {
  description = "Enable ZooKeeper for ClickHouse replication"
  type        = bool
  default     = false
}

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

# -----------------------------------------------------------------------------
# Users and Security
# -----------------------------------------------------------------------------

variable "create_users_secret" {
  description = "Create a Kubernetes secret for ClickHouse users"
  type        = bool
  default     = false
}

variable "clickhouse_users" {
  description = "Map of ClickHouse users to create"
  type = map(object({
    password = string
    profile  = optional(string, "default")
    quota    = optional(string, "default")
  }))
  default   = {}
  sensitive = true
}

# -----------------------------------------------------------------------------
# Additional Configuration
# -----------------------------------------------------------------------------

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}

variable "additional_clickhouse_settings" {
  description = "Additional ClickHouse server settings"
  type        = map(string)
  default     = {}
}
