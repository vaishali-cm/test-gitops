# Local deployment example for ClickHouse with Kafka
# Run: terraform init && terraform apply

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0, < 3.0.0"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0.0"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path    = "/Users/vaishalichanana/.kube/config"
    config_context = var.kube_context
  }
}

provider "kubectl" {
  config_path    = "/Users/vaishalichanana/.kube/config"
  config_context = var.kube_context
}

variable "kube_context" {
  description = "Kubernetes context to use"
  type        = string
  default     = "minikube"  # Change to your context
}

# -----------------------------------------------------------------------------
# Kafka Deployment (using Strimzi Operator)
# -----------------------------------------------------------------------------

# Install Strimzi Kafka Operator
resource "helm_release" "strimzi_operator" {
  name             = "strimzi"
  namespace        = "kafka"
  create_namespace = true

  repository = "https://strimzi.io/charts/"
  chart      = "strimzi-kafka-operator"
  version    = "0.43.0"

  timeout = 600
  wait    = true
}

# Deploy Kafka cluster using Strimzi CRD
resource "kubectl_manifest" "kafka_cluster" {
  yaml_body = <<-YAML
    apiVersion: kafka.strimzi.io/v1beta2
    kind: Kafka
    metadata:
      name: kafka
      namespace: kafka
    spec:
      kafka:
        version: 3.7.0
        replicas: 1
        listeners:
          - name: plain
            port: 9092
            type: internal
            tls: false
        config:
          offsets.topic.replication.factor: 1
          transaction.state.log.replication.factor: 1
          transaction.state.log.min.isr: 1
          default.replication.factor: 1
          min.insync.replicas: 1
          inter.broker.protocol.version: "3.7"
        storage:
          type: ephemeral
        resources:
          requests:
            cpu: "250m"
            memory: "512Mi"
          limits:
            cpu: "1"
            memory: "1Gi"
      zookeeper:
        replicas: 1
        storage:
          type: ephemeral
        resources:
          requests:
            cpu: "100m"
            memory: "256Mi"
          limits:
            cpu: "500m"
            memory: "512Mi"
      entityOperator:
        topicOperator: {}
        userOperator: {}
  YAML

  depends_on = [helm_release.strimzi_operator]
}

# Create topics
resource "kubectl_manifest" "kafka_topic_metrics" {
  yaml_body = <<-YAML
    apiVersion: kafka.strimzi.io/v1beta2
    kind: KafkaTopic
    metadata:
      name: metric-updates
      namespace: kafka
      labels:
        strimzi.io/cluster: kafka
    spec:
      partitions: 1
      replicas: 1
  YAML

  depends_on = [kubectl_manifest.kafka_cluster]
}

resource "kubectl_manifest" "kafka_topic_test" {
  yaml_body = <<-YAML
    apiVersion: kafka.strimzi.io/v1beta2
    kind: KafkaTopic
    metadata:
      name: test-topic
      namespace: kafka
      labels:
        strimzi.io/cluster: kafka
    spec:
      partitions: 1
      replicas: 1
  YAML

  depends_on = [kubectl_manifest.kafka_cluster]
}

# -----------------------------------------------------------------------------
# ClickHouse Deployment
# -----------------------------------------------------------------------------

module "clickhouse" {
  source = "../../modules/clickhouse-kafka"

  namespace    = "clickhouse"
  release_name = "clickhouse"

  # Kafka Configuration - points to Strimzi Kafka
  kafka_brokers        = "kafka-kafka-bootstrap.kafka.svc.cluster.local:9092"
  kafka_topics         = ["test-topic"]
  kafka_metric_topic   = "metric-updates"
  kafka_consumer_group = "clickhouse-local"
  kafka_format         = "JSONEachRow"

  # Minimal resources for local development
  shards   = 1
  replicas = 1

  cpu_request    = "250m"
  memory_request = "512Mi"
  cpu_limit      = "1"
  memory_limit   = "1Gi"

  # Storage - disabled for local dev (enable if you have a storage provisioner)
  persistence_enabled = false

  # Disable built-in ZooKeeper for single-node
  zookeeper_enabled = false

  depends_on = [kubectl_manifest.kafka_topic_metrics]
}

output "kafka_service" {
  value = "kafka-kafka-bootstrap.kafka.svc.cluster.local:9092"
}

output "clickhouse_service" {
  value = module.clickhouse.service_name
}

output "clickhouse_connect" {
  value = "kubectl port-forward -n clickhouse svc/${module.clickhouse.service_name} 8123:8123 9000:9000"
}

output "kafka_connect" {
  value = "kubectl port-forward -n kafka svc/kafka 9092:9092"
}
