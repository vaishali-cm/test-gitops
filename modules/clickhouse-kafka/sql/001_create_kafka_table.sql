-- Migration: 001_create_kafka_table
-- Creates Kafka engine table for ingesting metrics

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
