output "instance_name" {
  value = google_sql_database_instance.mysql_instance.name
}
output "instance_id" {
  description = "The ID of the Cloud SQL instance."
  value       = google_sql_database_instance.mysql_instance.id
}
output "instance_connection_name" {
  value = google_sql_database_instance.mysql_instance.connection_name
}
output "private_ip" {
  value = google_sql_database_instance.mysql_instance.private_ip_address
}
output "db_password" {
  description = "The generated password for the Cloud SQL user."
  value       = random_password.password.result
  sensitive   = true
}