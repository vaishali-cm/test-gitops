# FlinkSessionJob Module
# Creates a FlinkSessionJob custom resource for submitting jobs to an existing Flink Session cluster

resource "kubernetes_manifest" "flink_session_job" {
  manifest = {
    apiVersion = "flink.apache.org/v1beta1"
    kind       = "FlinkSessionJob"

    metadata = {
      name        = var.name
      namespace   = var.namespace
      labels      = var.labels
      annotations = var.annotations
    }

    spec = merge(
      {
        deploymentName = var.deployment_name

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
      },
      # Restart policy
      var.restart_nonce != null ? {
        restartNonce = var.restart_nonce
      } : {},
      # Flink configuration overrides for this job
      length(var.flink_configuration) > 0 ? {
        flinkConfiguration = var.flink_configuration
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
