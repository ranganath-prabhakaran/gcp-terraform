# terraform/outputs.tf
output "project_id" {
  value = var.project_id
}

output "region" {
  value = var.region
}

output "zone" {
  value = var.zone
}

output "mcp_server_ip" {
  value       = module.gce_mcp_server.private_ip
  description = "The private IP of the GCE instance running the MCP server."
}

output "mcp_server_name" {
  value = module.gce_mcp_server.instance_name
}

output "cloud_sql_instance_name" {
  value = module.cloud_sql.instance_name
}

output "cloud_sql_connection_name" {
  value = module.cloud_sql.instance_connection_name
}

output "cloud_sql_private_ip" {
  value = module.cloud_sql.private_ip
}

output "cloud_sql_database_name" {
  value = var.target_db_name
}

output "cloud_sql_user_name" {
  value = var.target_db_user
}

output "agent_service_account_email" {
  value = module.iam_secrets.service_account_email
}

output "source_db_password_secret_id" {
  value = module.iam_secrets.source_db_pass_secret_id
}

output "cloud_sql_password_secret_id" {
  value = module.iam_secrets.cloud_sql_password_secret_id
}

output "gcs_bucket_name" {
  value = module.gce_mcp_server.gcs_bucket_name
}

output "dms_source_profile_id" {
  value       = google_database_migration_service_connection_profile.source.connection_profile_id
  description = "ID of the DMS source connection profile."
}

output "dms_destination_profile_id" {
  value       = google_database_migration_service_connection_profile.destination.connection_profile_id
  description = "ID of the DMS destination connection profile."
}

