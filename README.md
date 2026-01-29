# Infrastructure GitOps Repository

Terraform configurations for deploying **Apache Flink** and **ClickHouse** (with Kafka integration) on Kubernetes.

## Repository Structure

```
.
├── modules/
│   ├── flink/                      # Flink Kubernetes Operator
│   │   ├── operator/               # Operator deployment
│   │   ├── deployment/             # FlinkDeployment resources
│   │   └── session-job/            # FlinkSessionJob resources
│   └── clickhouse-kafka/           # ClickHouse with Kafka Table Engine
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── versions.tf
│       ├── migrations/             # SQL migrations (run in order)
│       │   └── 001_init.sql
│       └── templates/
│           ├── clickhouse-migrations-configmap.yaml
│           └── clickhouse-run-migrations-job.yaml
├── environments/
│   ├── dev/
│   ├── staging/
│   └── prod/
├── examples/
│   ├── clickhouse-kafka-local/     # Local development setup
│   ├── flink-application/
│   └── flink-session-cluster/
└── README.md
```

## Prerequisites

- Terraform >= 1.5.0
- Kubernetes cluster (minikube, kind, Docker Desktop, or cloud)
- `kubectl` configured with cluster access
- Helm 3.x

## Quick Start: Local ClickHouse + Kafka

### 1. Start local Kubernetes

```bash
# Using Docker Desktop: Enable Kubernetes in settings

# Or using minikube:
minikube start --memory=4096 --cpus=2
```

### 2. Deploy ClickHouse with Kafka

```bash
cd examples/clickhouse-kafka-local

terraform init
terraform apply
```

This deploys:
- **Strimzi Kafka Operator** + Kafka cluster
- **Altinity ClickHouse Operator** + ClickHouse instance
- **SQL migrations** via Kubernetes Job

### 3. Verify deployment

```bash
# Check pods
kubectl get pods -n clickhouse
kubectl get pods -n kafka

# View migration logs
kubectl logs -n clickhouse -l job-name --tail=100

# Connect to ClickHouse
kubectl exec -it -n clickhouse chi-clickhouse-clickhouse-0-0-0 -- clickhouse-client

# Check tables
SHOW TABLES;
SELECT * FROM metric_updates;
```

### 4. Test Kafka → ClickHouse pipeline

```bash
# Terminal 1: Produce messages
kubectl exec -it -n kafka kafka-kafka-0 -- /opt/kafka/bin/kafka-console-producer.sh \
  --broker-list localhost:9092 \
  --topic metric-updates

# Enter JSON messages:
{"metric_name":"cpu","metric_value":45.2,"tags":{"host":"server1"},"timestamp":"2024-01-15 10:30:00"}
{"metric_name":"memory","metric_value":78.5,"tags":{"host":"server1"},"timestamp":"2024-01-15 10:30:01"}

# Terminal 2: Query ClickHouse
kubectl exec -it -n clickhouse chi-clickhouse-clickhouse-0-0-0 -- clickhouse-client \
  --query "SELECT * FROM metric_updates"
```

## Modules

### ClickHouse-Kafka Module

Deploys ClickHouse with Kafka Table Engine support.

```hcl
module "clickhouse" {
  source = "../../modules/clickhouse-kafka"

  namespace     = "clickhouse"
  release_name  = "clickhouse"
  kafka_brokers = "kafka-kafka-bootstrap.kafka.svc.cluster.local:9092"

  # Optional: force re-run migrations
  migrations_force_run = "v1"
}
```

**Features:**
- Altinity ClickHouse Operator
- Kafka Table Engine pre-configured
- SQL migrations via ConfigMap + Job
- Auto-detects migration changes via content hash

### SQL Migrations

SQL files in `modules/clickhouse-kafka/migrations/` run automatically in sorted order.

```bash
# Add a new migration
cat > modules/clickhouse-kafka/migrations/002_add_index.sql << 'EOF'
ALTER TABLE metric_updates ADD INDEX idx_name metric_name TYPE bloom_filter;
EOF

# Apply - creates new job with updated hash
terraform apply
```

**Force re-run** (when job template changes but SQL doesn't):

```hcl
module "clickhouse" {
  # ...
  migrations_force_run = "v2"  # bump this value
}
```

### Flink Module

```hcl
# Deploy Flink Operator
module "flink_operator" {
  source = "../../modules/flink/operator"

  namespace        = "flink"
  operator_version = "1.8.0"
}

# Deploy a Flink application
module "flink_app" {
  source = "../../modules/flink/deployment"

  namespace    = "flink"
  name         = "my-app"
  job_jar      = "local:///opt/flink/examples/streaming/WordCount.jar"
  parallelism  = 2
}
```

## Cleanup

```bash
# Destroy all resources
cd examples/clickhouse-kafka-local
terraform destroy

# Force cleanup stuck namespaces
kubectl delete namespace clickhouse --force --grace-period=0
kubectl delete namespace kafka --force --grace-period=0
```

## Troubleshooting

### Job won't update (immutable error)
```bash
# Delete old job, then re-apply
kubectl delete job -n clickhouse -l app=clickhouse --all
terraform apply
```

### Namespace stuck terminating
```bash
kubectl get namespace clickhouse -o json | \
  jq '.spec.finalizers = []' | \
  kubectl replace --raw "/api/v1/namespaces/clickhouse/finalize" -f -
```

### Check migration logs
```bash
kubectl logs -n clickhouse job/clickhouse-migrations-<hash>
```

### ClickHouse authentication error
The local setup disables authentication. For production, configure users in the `ClickHouseInstallation` spec.

## License

MIT
