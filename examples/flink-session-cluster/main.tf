# Example: Flink Session Cluster with Multiple Jobs
# Deploys a long-running Flink session cluster and submits jobs to it

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

  watch_namespaces = ["flink-session"]

  create_job_service_account = true
  job_service_account_name   = "flink"
}

# Create a Session Cluster
module "session_cluster" {
  source = "../../modules/flink/deployment"

  name          = "my-session-cluster"
  namespace     = "flink-session"
  mode          = "Session"
  flink_version = "v1_18"

  service_account = "flink"

  # Resources for the session cluster
  jobmanager_cpu       = 1
  jobmanager_memory    = "2048m"
  jobmanager_replicas  = 1

  taskmanager_cpu      = 2
  taskmanager_memory   = "4096m"
  taskmanager_replicas = 4
  task_slots           = 4

  # State backend
  state_backend = "rocksdb"

  # Enable ingress for Flink UI
  ingress_enabled = false

  # Additional Flink configuration
  flink_configuration = {
    "web.upload.dir"                      = "/opt/flink/uploads"
    "execution.checkpointing.interval"    = "60000"
    "execution.checkpointing.min-pause"   = "1000"
    "state.backend.incremental"           = "true"
  }

  labels = {
    app         = "flink-session"
    environment = "example"
  }

  depends_on = [module.flink_operator]
}

# Submit Job 1: Streaming ETL
module "streaming_etl_job" {
  source = "../../modules/flink/session-job"

  name            = "streaming-etl"
  namespace       = "flink-session"
  deployment_name = module.session_cluster.name

  job_jar_uri     = "https://repo1.maven.org/maven2/org/apache/flink/flink-examples-streaming_2.12/1.18.0/flink-examples-streaming_2.12-1.18.0-WordCount.jar"
  job_parallelism = 4
  job_upgrade_mode = "stateless"
  job_state        = "running"

  labels = {
    job  = "streaming-etl"
    team = "data-platform"
  }

  depends_on = [module.session_cluster]
}

# Submit Job 2: Real-time Analytics
module "analytics_job" {
  source = "../../modules/flink/session-job"

  name            = "real-time-analytics"
  namespace       = "flink-session"
  deployment_name = module.session_cluster.name

  job_jar_uri     = "https://repo1.maven.org/maven2/org/apache/flink/flink-examples-streaming_2.12/1.18.0/flink-examples-streaming_2.12-1.18.0-TopSpeedWindowing.jar"
  job_parallelism = 2
  job_upgrade_mode = "stateless"
  job_state        = "running"

  # Job-specific configuration
  flink_configuration = {
    "pipeline.name" = "Real-Time Analytics Pipeline"
  }

  labels = {
    job  = "real-time-analytics"
    team = "analytics"
  }

  depends_on = [module.session_cluster]
}

# Outputs
output "session_cluster_name" {
  value = module.session_cluster.name
}

output "session_cluster_service" {
  value = module.session_cluster.service_name
}

output "streaming_etl_job_name" {
  value = module.streaming_etl_job.name
}

output "analytics_job_name" {
  value = module.analytics_job.name
}
