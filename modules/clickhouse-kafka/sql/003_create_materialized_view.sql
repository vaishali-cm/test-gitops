-- Migration: 003_create_materialized_view
-- Creates materialized view to pipe data from Kafka to MergeTree

CREATE MATERIALIZED VIEW IF NOT EXISTS metric_updates_mv TO metric_updates AS
SELECT * FROM metric_updates_queue;
