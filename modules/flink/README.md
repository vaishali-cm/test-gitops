# Flink Modules

This directory contains Terraform modules for deploying Apache Flink on Kubernetes using the Flink Kubernetes Operator.

## Module Structure

```
flink/
├── operator/         # Flink Kubernetes Operator (Helm deployment)
├── deployment/       # FlinkDeployment CRD (Application or Session cluster)
└── session-job/      # FlinkSessionJob CRD (Jobs for Session clusters)
```

## Modules

### 1. Operator Module (`operator/`)

Deploys the Flink Kubernetes Operator via Helm chart.

**Usage:**

```hcl
module "flink_operator" {
  source = "../../modules/flink/operator"

  namespace        = "flink"
  release_name     = "flink-kubernetes-operator"
  chart_version    = "1.8.0"
  create_namespace = true

  operator_replicas = 1
  webhook_enabled   = true
  metrics_enabled   = true

  resource_requests = {
    cpu    = "100m"
    memory = "256Mi"
  }

  resource_limits = {
    cpu    = "500m"
    memory = "512Mi"
  }

  # Watch specific namespaces (empty = all)
  watch_namespaces = ["flink", "flink-jobs"]

  # Create ServiceAccount for Flink jobs
  create_job_service_account = true
  job_service_account_name   = "flink"
}
```

### 2. Deployment Module (`deployment/`)

Creates a FlinkDeployment custom resource. Supports both **Application** and **Session** modes.

#### Application Mode

For running a single Flink job with dedicated resources:

```hcl
module "flink_app" {
  source = "../../modules/flink/deployment"

  name          = "my-flink-app"
  namespace     = "flink"
  mode          = "Application"
  flink_version = "v1_18"

  # Job configuration
  job_jar_uri     = "local:///opt/flink/usrlib/my-job.jar"
  job_entry_class = "com.example.MyFlinkJob"
  job_parallelism = 4
  job_args        = ["--input", "kafka://...", "--output", "s3://..."]

  # Resources
  jobmanager_cpu      = 1
  jobmanager_memory   = "2048m"
  taskmanager_cpu     = 2
  taskmanager_memory  = "4096m"
  taskmanager_replicas = 3

  # State management
  state_backend           = "rocksdb"
  checkpoint_storage_path = "s3://my-bucket/checkpoints"
  savepoint_storage_path  = "s3://my-bucket/savepoints"

  # High availability
  ha_enabled      = true
  ha_storage_path = "s3://my-bucket/ha"
}
```

#### Session Mode

For creating a long-running cluster that accepts multiple jobs:

```hcl
module "flink_session" {
  source = "../../modules/flink/deployment"

  name          = "my-session-cluster"
  namespace     = "flink"
  mode          = "Session"
  flink_version = "v1_18"

  # Resources
  jobmanager_cpu       = 1
  jobmanager_memory    = "2048m"
  taskmanager_cpu      = 2
  taskmanager_memory   = "4096m"
  taskmanager_replicas = 4
  task_slots           = 4

  # State management
  state_backend           = "rocksdb"
  checkpoint_storage_path = "s3://my-bucket/checkpoints"
}
```

### 3. Session Job Module (`session-job/`)

Submits a job to an existing Flink Session cluster.

```hcl
module "my_session_job" {
  source = "../../modules/flink/session-job"

  name            = "my-streaming-job"
  namespace       = "flink"
  deployment_name = "my-session-cluster"  # Reference to FlinkDeployment

  job_jar_uri     = "https://repo.example.com/jobs/my-job-1.0.jar"
  job_entry_class = "com.example.StreamingJob"
  job_parallelism = 4
  job_args        = ["--kafka.bootstrap.servers", "kafka:9092"]

  # Upgrade strategy
  job_upgrade_mode = "savepoint"
  job_state        = "running"

  # Job-specific configuration overrides
  flink_configuration = {
    "execution.checkpointing.interval" = "60000"
    "execution.checkpointing.mode"     = "EXACTLY_ONCE"
  }

  labels = {
    app     = "my-streaming-job"
    version = "1.0"
  }
}
```

## Complete Example

Deploy operator, create a session cluster, and submit jobs:

```hcl
# 1. Deploy the Flink Kubernetes Operator
module "flink_operator" {
  source = "../../modules/flink/operator"

  namespace     = "flink-system"
  chart_version = "1.8.0"

  watch_namespaces = ["flink-apps"]
}

# 2. Create a Session cluster
module "flink_session" {
  source = "../../modules/flink/deployment"

  name          = "production-session"
  namespace     = "flink-apps"
  mode          = "Session"
  flink_version = "v1_18"

  taskmanager_replicas = 6
  task_slots           = 4

  depends_on = [module.flink_operator]
}

# 3. Submit jobs to the session cluster
module "etl_job" {
  source = "../../modules/flink/session-job"

  name            = "etl-pipeline"
  namespace       = "flink-apps"
  deployment_name = module.flink_session.name

  job_jar_uri     = "s3://jobs/etl-pipeline-2.0.jar"
  job_entry_class = "com.example.ETLPipeline"
  job_parallelism = 8

  depends_on = [module.flink_session]
}

module "analytics_job" {
  source = "../../modules/flink/session-job"

  name            = "real-time-analytics"
  namespace       = "flink-apps"
  deployment_name = module.flink_session.name

  job_jar_uri     = "s3://jobs/analytics-1.5.jar"
  job_entry_class = "com.example.Analytics"
  job_parallelism = 4

  depends_on = [module.flink_session]
}
```

## Flink Versions

The `flink_version` variable uses the operator's versioning scheme:

| Flink Version | Variable Value |
|---------------|----------------|
| 1.18.x        | `v1_18`        |
| 1.17.x        | `v1_17`        |
| 1.16.x        | `v1_16`        |

## Upgrade Modes

| Mode        | Description                                              |
|-------------|----------------------------------------------------------|
| `stateless` | No state is preserved during upgrades                    |
| `savepoint` | Takes a savepoint before upgrade, restores after        |
| `last-state`| Uses last checkpoint/savepoint for recovery             |

## State Backends

| Backend    | Use Case                                                |
|------------|---------------------------------------------------------|
| `hashmap`  | Development/testing, small state                        |
| `rocksdb`  | Production, large state, incremental checkpoints       |
