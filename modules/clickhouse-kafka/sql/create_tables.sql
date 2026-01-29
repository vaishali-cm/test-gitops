-- ClickHouse Kafka Table Engine Setup
-- Creates metric_updates table with Kafka source

-- Create Kafka engine table (source)
CREATE TABLE IF NOT EXISTS metric_updates_queue (
    metric_name String,
    metric_value Float64,
    tags Map(String, String),
    timestamp DateTime64(3)
) ENGINE = Kafka
SETTINGS
    kafka_broker_list = '${KAFKA_BROKERS}',
    kafka_topic_list = '${KAFKA_TOPIC}',
    kafka_group_name = '${KAFKA_CONSUMER_GROUP}',
    kafka_format = '${KAFKA_FORMAT}',
    kafka_num_consumers = ${KAFKA_NUM_CONSUMERS};

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
