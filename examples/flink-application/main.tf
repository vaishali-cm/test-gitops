# Example: Flink Application Mode Deployment
# Deploys a standalone Flink application with its own cluster

terraform {
  required_version = ">= 1.5.0"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

# Deploy the Flink Kubernetes Operator
module "flink_operator" {
  source = "../../modules/flink/operator"

  namespace        = "flink-system"
  release_name     = "flink-kubernetes-operator"
  chart_version    = "1.8.0"
  create_namespace = true

  watch_namespaces = []  # Watch all namespaces

  create_job_service_account = true
  job_service_account_name   = "flink"

  labels = {
    environment = "example"
  }
}

# Deploy a Flink Application
module "word_count_app" {
  source = "../../modules/flink/deployment"

  name          = "word-count"
  namespace     = "flink-apps"
  mode          = "Application"
  flink_version = "v1_18"
  
  service_account = module.flink_operator.job_service_account_name

  # Use the official Flink examples image
  image = "flink:1.18"

  # Job configuration
  job_jar_uri     = "local:///opt/flink/examples/streaming/WordCount.jar"
  job_parallelism = 2
  job_upgrade_mode = "stateless"
  job_state        = "running"

  # Resources
  jobmanager_cpu      = 0.5
  jobmanager_memory   = "1024m"
  taskmanager_cpu     = 1
  taskmanager_memory  = "2048m"
  taskmanager_replicas = 2
  task_slots          = 2

  # State configuration
  state_backend = "hashmap"

  labels = {
    app         = "word-count"
    environment = "example"
  }

  depends_on = [module.flink_operator]
}

# Outputs
output "operator_namespace" {
  value = module.flink_operator.namespace
}

output "app_name" {
  value = module.word_count_app.name
}

output "app_service" {
  value = module.word_count_app.service_name
}
