-- Migration: 001_init
-- Initial setup for ClickHouse Kafka integration

-- Create Kafka engine table (source)
CREATE TABLE IF NOT EXISTS metric_updates_queue (
    metric_name String,
    metric_value Float64,
    tags Map(String, String),
    timestamp DateTime64(3)
) ENGINE = Kafka
SETTINGS
    kafka_broker_list = 'kafka-kafka-bootstrap.kafka.svc.cluster.local:9092',
    kafka_topic_list = 'metric-updates',
    kafka_group_name = 'clickhouse-metrics',
    kafka_format = 'JSONEachRow',
    kafka_num_consumers = 1;

-- Create MergeTree table (destination)
CREATE TABLE IF NOT EXISTS metric_updates (
    metric_name String,
    metric_value Float64,
    tags Map(String, String),
    timestamp DateTime64(3)
) ENGINE = MergeTree()
PARTITION BY toYYYYMM(timestamp)
ORDER BY (metric_name, timestamp);

-- Create materialized view to pipe data from Kafka to MergeTree
CREATE MATERIALIZED VIEW IF NOT EXISTS metric_updates_mv TO metric_updates AS
SELECT * FROM metric_updates_queue;
