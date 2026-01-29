-- Migration: 002_create_destination_table
-- Creates MergeTree destination table for metrics

CREATE TABLE IF NOT EXISTS metric_updates (
    metric_name String,
    metric_value Float64,
    tags Map(String, String),
    timestamp DateTime64(3)
) ENGINE = MergeTree()
PARTITION BY toYYYYMM(timestamp)
ORDER BY (metric_name, timestamp);
