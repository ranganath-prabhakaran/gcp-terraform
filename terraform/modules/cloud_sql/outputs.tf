output "instance_name" {
  value = google_sql_database_instance.mysql_instance.name
}
output "instance_connection_name" {
  value = google_sql_database_instance.mysql_instance.connection_name
}
output "private_ip" {
  value = google_sql_database_instance.mysql_instance.private_ip_address
}