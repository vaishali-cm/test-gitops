# Example: ClickHouse with Kafka Table Engine
# Minimal deployment for consuming data from Kafka

terraform {
  required_version = ">= 1.5.0"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

module "clickhouse" {
  source = "../../modules/clickhouse-kafka"

  namespace    = "clickhouse"
  release_name = "clickhouse-kafka"

  # Kafka Configuration
  kafka_brokers        = "kafka-0.kafka:9092,kafka-1.kafka:9092,kafka-2.kafka:9092"
  kafka_topics         = ["events", "logs", "metrics"]
  kafka_consumer_group = "clickhouse-consumer"
  kafka_format         = "JSONEachRow"

  # Resources (adjust for your environment)
  cpu_request    = "500m"
  memory_request = "2Gi"
  cpu_limit      = "2"
  memory_limit   = "4Gi"

  # Storage
  storage_size  = "100Gi"
  storage_class = "standard"
}

output "clickhouse_service" {
  value = module.clickhouse.service_name
}

# =============================================================================
# Example: Create Kafka Table and Materialized View
# =============================================================================
#
# After deploying, connect to ClickHouse and create tables:
#
# -- 1. Create a Kafka engine table (reads from Kafka topic)
# CREATE TABLE events_queue (
#     event_id UUID,
#     event_type String,
#     user_id UInt64,
#     timestamp DateTime,
#     payload String
# ) ENGINE = Kafka
# SETTINGS
#     kafka_broker_list = 'kafka:9092',
#     kafka_topic_list = 'events',
#     kafka_group_name = 'clickhouse-events',
#     kafka_format = 'JSONEachRow',
#     kafka_num_consumers = 2;
#
# -- 2. Create a destination table (MergeTree for storage)
# CREATE TABLE events (
#     event_id UUID,
#     event_type String,
#     user_id UInt64,
#     timestamp DateTime,
#     payload String
# ) ENGINE = MergeTree()
# ORDER BY (event_type, timestamp);
#
# -- 3. Create a materialized view (pipes data from Kafka to MergeTree)
# CREATE MATERIALIZED VIEW events_mv TO events AS
# SELECT * FROM events_queue;
#
# =============================================================================
