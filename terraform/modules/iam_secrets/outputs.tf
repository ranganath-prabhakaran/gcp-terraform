output "service_account_email" {
  value = google_service_account.agent_sa.email
}
output "source_db_pass_secret_id" {
  value = google_secret_manager_secret.source_db_password.id
}
output "cloud_sql_password_secret_id" {
  value = google_secret_manager_secret.cloud_sql_password.id
}