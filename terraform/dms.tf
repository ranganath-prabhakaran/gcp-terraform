data "google_project" "project" {
}

resource "google_project_iam_member" "dms_service_agent_role" {
  provider = google-beta
  project  = var.project_id
  role     = "roles/cloudsql.client"
  member   = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-dms.iam.gserviceaccount.com"
}

resource "google_database_migration_service_connection_profile" "source" {
  provider              = google
  location              = var.region
  connection_profile_id = "${var.prefix}-dms-source-profile"
  display_name          = "DMS Source Profile (via MCP)"

  mysql {
    host     = module.gce_mcp_server.private_ip
    port     = 3306 # Port where MCP server exposes the proxied DB
    username = var.source_db_user
    password = module.iam_secrets.source_db_password
  }

  depends_on = [module.gce_mcp_server]
}

resource "google_database_migration_service_connection_profile" "destination" {
  provider              = google 
  location              = var.region
  connection_profile_id = "${var.prefix}-dms-dest-profile"
  display_name          = "DMS Destination Profile (Cloud SQL)"

  mysql {
    host         = module.cloud_sql.private_ip
    port         = 3306
    username     = var.target_db_user
    password     = module.cloud_sql.db_password
  }

  depends_on = [module.cloud_sql]
}


