resource "google_database_migration_service_connection_profile" "source" {
  provider              = google
  location              = var.region
  connection_profile_id = "${var.prefix}-dms-source-profile"
  display_name          = "DMS Source Profile (via MCP)"

  mysql {
    host     = module.gce_mcp_server.private_ip
    port     = 3306 # Port where MCP server exposes the proxied DB
    username = var.source_db_user
    password = data.google_secret_manager_secret_version.source_db_password.secret_data
  }

  depends_on = [module.gce_mcp_server]
}

resource "google_database_migration_service_connection_profile" "destination" {
  provider              = google
  location              = var.region
  connection_profile_id = "${var.prefix}-dms-dest-profile"
  display_name          = "DMS Destination Profile (Cloud SQL)"

  mysql {
    cloud_sql_id = module.cloud_sql.instance_name
    username     = var.target_db_user
    password     = data.google_secret_manager_secret_version.cloud_sql_password.secret_data
  }

  depends_on = [module.cloud_sql]
}

resource "google_database_migration_service_migration_job" "mysql_migration" {
  provider         = google
  location         = var.region
  migration_job_id = "${var.prefix}-dms-job"
  display_name     = "Agentic MySQL to Cloud SQL Migration"
  type             = "ONE_TIME" # Can be changed to CONTINUOUS if needed
  source           = google_database_migration_service_connection_profile.source.id
  destination      = google_database_migration_service_connection_profile.destination.id

  # The job is defined here, but will be started by the agentic workflow.
  state = "STOPPED"

  labels = {
    "created-by" = "agentic-migration-framework"
  }

  depends_on = [
    google_database_migration_service_connection_profile.source,
    google_database_migration_service_connection_profile.destination,
  ]
}