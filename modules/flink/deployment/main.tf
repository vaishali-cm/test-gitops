# FlinkDeployment Module
# Creates a FlinkDeployment custom resource for deploying Flink applications or session clusters

resource "kubernetes_manifest" "flink_deployment" {
  manifest = {
    apiVersion = "flink.apache.org/v1beta1"
    kind       = "FlinkDeployment"

    metadata = {
      name      = var.name
      namespace = var.namespace
      labels    = var.labels
      annotations = var.annotations
    }

    spec = merge(
      {
        flinkVersion = var.flink_version
        image        = var.image != null ? var.image : "flink:${var.flink_version}"
        mode         = var.mode
        
        serviceAccount = var.service_account

        flinkConfiguration = merge(
          {
            "taskmanager.numberOfTaskSlots" = tostring(var.task_slots)
            "state.backend"                 = var.state_backend
          },
          var.state_backend == "rocksdb" ? {
            "state.backend.rocksdb.localdir" = "/tmp/rocksdb"
          } : {},
          var.checkpoint_storage_path != null ? {
            "state.checkpoints.dir" = var.checkpoint_storage_path
          } : {},
          var.savepoint_storage_path != null ? {
            "state.savepoints.dir" = var.savepoint_storage_path
          } : {},
          var.ha_enabled ? {
            "high-availability"                          = "kubernetes"
            "high-availability.storageDir"              = var.ha_storage_path
            "kubernetes.operator.job.restart.failed"   = "true"
          } : {},
          var.flink_configuration
        )

        jobManager = {
          resource = {
            cpu    = var.jobmanager_cpu
            memory = var.jobmanager_memory
          }
          replicas = var.jobmanager_replicas
          podTemplate = var.jobmanager_pod_template
        }

        taskManager = {
          resource = {
            cpu    = var.taskmanager_cpu
            memory = var.taskmanager_memory
          }
          replicas = var.taskmanager_replicas
          podTemplate = var.taskmanager_pod_template
        }
      },
      # Add job spec only for Application mode
      var.mode == "Application" && var.job_jar_uri != null ? {
        job = merge(
          {
            jarURI      = var.job_jar_uri
            parallelism = var.job_parallelism
            upgradeMode = var.job_upgrade_mode
            state       = var.job_state
          },
          var.job_entry_class != null ? {
            entryClass = var.job_entry_class
          } : {},
          length(var.job_args) > 0 ? {
            args = var.job_args
          } : {},
          var.job_savepoint_path != null ? {
            initialSavepointPath = var.job_savepoint_path
          } : {},
          var.job_allow_non_restored_state ? {
            allowNonRestoredState = var.job_allow_non_restored_state
          } : {}
        )
      } : {},
      # Ingress configuration
      var.ingress_enabled ? {
        ingress = {
          template = var.ingress_host
          className = var.ingress_class
          annotations = var.ingress_annotations
        }
      } : {},
      # Pod template
      var.pod_template != null ? {
        podTemplate = var.pod_template
      } : {},
      # Log configuration
      var.log_configuration != null ? {
        logConfiguration = var.log_configuration
      } : {}
    )
  }

  field_manager {
    force_conflicts = var.force_conflicts
  }

  timeouts {
    create = var.timeout_create
    update = var.timeout_update
    delete = var.timeout_delete
  }
}
