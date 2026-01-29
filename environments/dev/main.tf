# Development Environment
# Deploys Flink and ClickHouse for development/testing

terraform {
  required_version = ">= 1.5.0"

  # Configure your backend here
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "dev/terraform.tfstate"
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
  release_name     = "flink-operator-dev"
  create_namespace = true

  chart_version     = var.flink_operator_version
  operator_replicas = 1

  resource_requests = {
    cpu    = "100m"
    memory = "256Mi"
  }

  resource_limits = {
    cpu    = "500m"
    memory = "512Mi"
  }

  # Watch the Flink namespace
  watch_namespaces = ["flink-dev"]

  # Create ServiceAccount for jobs
  create_job_service_account = true
  job_service_account_name   = "flink"

  labels = local.common_labels
}

# -----------------------------------------------------------------------------
# Flink Session Cluster (Development)
# -----------------------------------------------------------------------------

module "flink_session" {
  source = "../../modules/flink/deployment"

  name          = "dev-session"
  namespace     = "flink-dev"
  mode          = "Session"
  flink_version = var.flink_version

  service_account = "flink"

  # Dev environment uses smaller resources
  jobmanager_cpu       = 0.5
  jobmanager_memory    = "1024m"
  taskmanager_cpu      = 1
  taskmanager_memory   = "2048m"
  taskmanager_replicas = 2
  task_slots           = 2

  state_backend = "hashmap"

  flink_configuration = {
    "execution.checkpointing.interval" = "60000"
  }

  labels = local.common_labels

  depends_on = [module.flink_operator]
}

# -----------------------------------------------------------------------------
# ClickHouse Module
# -----------------------------------------------------------------------------

module "clickhouse" {
  source = "../../modules/clickhouse"

  namespace          = "clickhouse-dev"
  operator_namespace = "clickhouse-operator"
  release_name       = "clickhouse-dev"
  create_namespace   = true

  # Dev environment configuration
  operator_version   = var.clickhouse_operator_version
  deploy_cluster     = true
  cluster_name       = "dev-cluster"
  cluster_replicas   = 1  # Single replica for dev
  cluster_shards     = 1
  clickhouse_version = var.clickhouse_version

  storage_class = var.storage_class
  storage_size  = "20Gi"  # Smaller storage for dev

  resource_requests = {
    cpu    = "250m"
    memory = "1Gi"
  }

  resource_limits = {
    cpu    = "1"
    memory = "2Gi"
  }

  # No ZooKeeper needed for single replica
  zookeeper_enabled = false

  labels = local.common_labels
}

# -----------------------------------------------------------------------------
# Locals
# -----------------------------------------------------------------------------

locals {
  common_labels = {
    environment = "dev"
    managed_by  = "terraform"
    team        = var.team_name
  }
}
