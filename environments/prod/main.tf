# Production Environment
# Deploys Flink and ClickHouse for production workloads

terraform {
  required_version = ">= 1.5.0"

  # Configure your backend here
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "prod/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-locks"
  # }
}

# -----------------------------------------------------------------------------
# Provider Configuration
# -----------------------------------------------------------------------------

provider "kubernetes" {
  config_path    = var.kubeconfig_path
  config_context = var.kubeconfig_context
}

provider "helm" {
  kubernetes {
    config_path    = var.kubeconfig_path
    config_context = var.kubeconfig_context
  }
}

# -----------------------------------------------------------------------------
# Flink Kubernetes Operator
# -----------------------------------------------------------------------------

module "flink_operator" {
  source = "../../modules/flink/operator"

  namespace        = "flink-system"
  release_name     = "flink-operator-prod"
  create_namespace = true

  chart_version     = var.flink_operator_version
  operator_replicas = 2  # HA for production

  resource_requests = {
    cpu    = "500m"
    memory = "1Gi"
  }

  resource_limits = {
    cpu    = "2"
    memory = "2Gi"
  }

  watch_namespaces = ["flink-prod"]

  create_job_service_account    = true
  job_service_account_name      = "flink"
  job_service_account_annotations = var.flink_service_account_annotations

  labels = local.common_labels
}

# -----------------------------------------------------------------------------
# Flink Session Cluster (Production)
# -----------------------------------------------------------------------------

module "flink_session" {
  source = "../../modules/flink/deployment"

  name          = "prod-session"
  namespace     = "flink-prod"
  mode          = "Session"
  flink_version = var.flink_version

  service_account = "flink"

  # Production resources
  jobmanager_cpu       = var.flink_jobmanager_cpu
  jobmanager_memory    = var.flink_jobmanager_memory
  jobmanager_replicas  = 1

  taskmanager_cpu      = var.flink_taskmanager_cpu
  taskmanager_memory   = var.flink_taskmanager_memory
  taskmanager_replicas = var.flink_taskmanager_replicas
  task_slots           = var.flink_task_slots

  # State management
  state_backend           = "rocksdb"
  checkpoint_storage_path = var.flink_checkpoint_path
  savepoint_storage_path  = var.flink_savepoint_path

  # High availability
  ha_enabled      = true
  ha_storage_path = var.flink_ha_path

  flink_configuration = {
    # Checkpointing
    "execution.checkpointing.interval"                          = "30000"
    "execution.checkpointing.mode"                              = "EXACTLY_ONCE"
    "execution.checkpointing.min-pause"                         = "5000"
    "execution.checkpointing.externalized-checkpoint-retention" = "RETAIN_ON_CANCELLATION"
    "state.checkpoints.num-retained"                            = "3"
    "state.backend.incremental"                                 = "true"
    
    # Restart strategy
    "restart-strategy"                        = "fixed-delay"
    "restart-strategy.fixed-delay.attempts"   = "3"
    "restart-strategy.fixed-delay.delay"      = "10s"
    
    # Memory tuning
    "taskmanager.memory.managed.fraction" = "0.4"
  }

  labels = local.common_labels

  depends_on = [module.flink_operator]
}

# -----------------------------------------------------------------------------
# ClickHouse Module
# -----------------------------------------------------------------------------

module "clickhouse" {
  source = "../../modules/clickhouse"

  namespace          = "clickhouse-prod"
  operator_namespace = "clickhouse-operator"
  release_name       = "clickhouse-prod"
  create_namespace   = true

  operator_version   = var.clickhouse_operator_version
  operator_replicas  = 2  # HA for operator
  deploy_cluster     = true
  cluster_name       = "prod-cluster"
  cluster_replicas   = var.clickhouse_replicas
  cluster_shards     = var.clickhouse_shards
  clickhouse_version = var.clickhouse_version

  storage_class = var.storage_class
  storage_size  = var.clickhouse_storage_size

  resource_requests = {
    cpu    = var.clickhouse_cpu_request
    memory = var.clickhouse_memory_request
  }

  resource_limits = {
    cpu    = var.clickhouse_cpu_limit
    memory = var.clickhouse_memory_limit
  }

  # ZooKeeper is required for production replication
  zookeeper_enabled   = true
  zookeeper_namespace = var.zookeeper_namespace
  zookeeper_service   = var.zookeeper_service

  additional_clickhouse_settings = {
    max_concurrent_queries = "200"
    max_connections        = "8192"
    mark_cache_size        = "5368709120"  # 5GB
  }

  labels = local.common_labels
}

# -----------------------------------------------------------------------------
# Locals
# -----------------------------------------------------------------------------

locals {
  common_labels = {
    environment = "prod"
    managed_by  = "terraform"
    team        = var.team_name
    criticality = "high"
  }
}
