# Flink Configuration
taskmanager.memory.process.size: ${taskmanager_memory}
jobmanager.memory.process.size: ${jobmanager_memory}
parallelism.default: ${parallelism_default}

# Checkpointing
execution.checkpointing.interval: ${checkpoint_interval}
state.backend: ${state_backend}

# High Availability (uncomment if needed)
# high-availability: kubernetes
# high-availability.storageDir: s3://flink-ha/

%{ for key, value in additional_flink_config ~}
${key}: ${value}
%{ endfor ~}
