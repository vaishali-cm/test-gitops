# Local ClickHouse with Kafka Deployment

## Quick Start

### 1. Start a local Kubernetes cluster

```bash
# Option A: minikube
minikube start --memory=4096 --cpus=2

# Option B: kind
kind create cluster --name clickhouse-local

# Option C: Docker Desktop
# Enable Kubernetes in Docker Desktop settings
```

### 2. (Optional) Deploy Kafka

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm install kafka bitnami/kafka \
  --namespace kafka \
  --create-namespace \
  --set controller.replicaCount=1 \
  --set listeners.client.protocol=PLAINTEXT
```

### 3. Deploy ClickHouse

```bash
cd examples/clickhouse-kafka-local

# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Deploy
terraform apply
```

### 4. Connect to ClickHouse

```bash
# Port forward
kubectl port-forward -n clickhouse svc/clickhouse-clickhouse 8123:8123 9000:9000

# Connect via HTTP (in another terminal)
curl http://localhost:8123

# Connect via clickhouse-client
clickhouse-client --host localhost --port 9000
```

### 5. Create a Kafka table (example)

```sql
-- Connect to ClickHouse first, then run:

CREATE TABLE kafka_events (
    id UInt64,
    message String,
    timestamp DateTime
) ENGINE = Kafka
SETTINGS
    kafka_broker_list = 'kafka.kafka.svc.cluster.local:9092',
    kafka_topic_list = 'test-topic',
    kafka_group_name = 'clickhouse-local',
    kafka_format = 'JSONEachRow';

-- Create destination table
CREATE TABLE events (
    id UInt64,
    message String,
    timestamp DateTime
) ENGINE = MergeTree()
ORDER BY timestamp;

-- Create materialized view to pipe data
CREATE MATERIALIZED VIEW events_mv TO events
AS SELECT * FROM kafka_events;
```

### 6. Test with Kafka

```bash
# Produce a test message
kubectl exec -n kafka kafka-controller-0 -- \
  kafka-console-producer.sh \
  --broker-list localhost:9092 \
  --topic test-topic <<< '{"id": 1, "message": "hello", "timestamp": "2024-01-01 00:00:00"}'

# Check ClickHouse
curl "http://localhost:8123/?query=SELECT%20*%20FROM%20events"
```

## Cleanup

```bash
terraform destroy
kubectl delete namespace kafka
minikube stop  # or: kind delete cluster --name clickhouse-local
```

## Troubleshooting

**Pod stuck in Pending:**
```bash
kubectl describe pod -n clickhouse
# Check if storage class exists
kubectl get storageclass
```

**Connection refused:**
```bash
# Check pod status
kubectl get pods -n clickhouse
kubectl logs -n clickhouse -l app.kubernetes.io/name=clickhouse
```

**Kafka connection issues:**
```bash
# Test Kafka connectivity from ClickHouse pod
kubectl exec -n clickhouse -it $(kubectl get pod -n clickhouse -l app.kubernetes.io/name=clickhouse -o jsonpath='{.items[0].metadata.name}') -- \
  nc -zv kafka.kafka.svc.cluster.local 9092
```
