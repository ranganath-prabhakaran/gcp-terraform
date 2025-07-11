resource "google_service_account" "agent_sa" {
  project      = var.project_id
  account_id   = "${var.prefix}-sa"
  display_name = "Service Account for Agentic Migration"
}

# Grant necessary roles to the Service Account
resource "google_project_iam_member" "sa_roles" {
  project = var.project_id
  for_each = toset([
    "roles/compute.instanceAdmin.v1",
    "roles/iam.serviceAccountUser",
    "roles/cloudsql.client",
    "roles/secretmanager.secretAccessor",
    "roles/storage.objectAdmin",
    "roles/datamigration.viewer",
    "roles/datamigration.user",
    "roles/monitoring.viewer",
    "roles/logging.logWriter"
  ])
  role   = each.key
  member = "serviceAccount:${google_service_account.agent_sa.email}"
}

# Create secret containers (NOT versions)
resource "google_secret_manager_secret" "source_db_password" {
  project   = var.project_id
  secret_id = var.source_db_pass_secret_name
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "cloud_sql_password" {
  project   = var.project_id
  secret_id = var.cloud_sql_pass_secret_name
  replication {
    auto {}
  }
}

# Data sources to read the secrets for DMS profiles
data "google_secret_manager_secret_version" "source_db_password" {
  project = var.project_id
  secret  = var.source_db_pass_secret_name
}

data "google_secret_manager_secret_version" "cloud_sql_password" {
  project = var.project_id
  secret  = var.cloud_sql_pass_secret_name
}