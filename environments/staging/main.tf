# Staging Environment
# Deploys Flink and ClickHouse for staging/pre-production

terraform {
  required_version = ">= 1.5.0"

  # Configure your backend here
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "staging/terraform.tfstate"
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
  release_name     = "flink-operator-staging"
  create_namespace = true

  chart_version     = var.flink_operator_version
  operator_replicas = 1

  resource_requests = {
    cpu    = "200m"
    memory = "512Mi"
  }

  resource_limits = {
    cpu    = "1"
    memory = "1Gi"
  }

  watch_namespaces = ["flink-staging"]

  create_job_service_account = true
  job_service_account_name   = "flink"

  labels = local.common_labels
}

# -----------------------------------------------------------------------------
# Flink Session Cluster (Staging)
# -----------------------------------------------------------------------------

module "flink_session" {
  source = "../../modules/flink/deployment"

  name          = "staging-session"
  namespace     = "flink-staging"
  mode          = "Session"
  flink_version = var.flink_version

  service_account = "flink"

  # Staging resources - closer to production
  jobmanager_cpu       = 1
  jobmanager_memory    = "2048m"
  taskmanager_cpu      = 2
  taskmanager_memory   = "4096m"
  taskmanager_replicas = 4
  task_slots           = 4

  state_backend           = "rocksdb"
  checkpoint_storage_path = var.flink_checkpoint_path
  savepoint_storage_path  = var.flink_savepoint_path

  flink_configuration = {
    "execution.checkpointing.interval"  = "60000"
    "execution.checkpointing.mode"      = "EXACTLY_ONCE"
    "state.backend.incremental"         = "true"
  }

  labels = local.common_labels

  depends_on = [module.flink_operator]
}

# -----------------------------------------------------------------------------
# ClickHouse Module
# -----------------------------------------------------------------------------

module "clickhouse" {
  source = "../../modules/clickhouse"

  namespace          = "clickhouse-staging"
  operator_namespace = "clickhouse-operator"
  release_name       = "clickhouse-staging"
  create_namespace   = true

  operator_version   = var.clickhouse_operator_version
  deploy_cluster     = true
  cluster_name       = "staging-cluster"
  cluster_replicas   = 2  # 2 replicas for HA testing
  cluster_shards     = 1
  clickhouse_version = var.clickhouse_version

  storage_class = var.storage_class
  storage_size  = "50Gi"

  resource_requests = {
    cpu    = "500m"
    memory = "2Gi"
  }

  resource_limits = {
    cpu    = "2"
    memory = "4Gi"
  }

  # Enable ZooKeeper for replication
  zookeeper_enabled   = var.zookeeper_enabled
  zookeeper_namespace = var.zookeeper_namespace
  zookeeper_service   = var.zookeeper_service

  labels = local.common_labels
}

# -----------------------------------------------------------------------------
# Locals
# -----------------------------------------------------------------------------

locals {
  common_labels = {
    environment = "staging"
    managed_by  = "terraform"
    team        = var.team_name
  }
}
