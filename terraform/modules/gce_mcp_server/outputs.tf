output "private_ip" {
  value = google_compute_instance.mcp_server.network_interface[0].network_ip
}
output "instance_name" {
  value = google_compute_instance.mcp_server.name
}
output "gcs_bucket_name" {
  value = google_storage_bucket.migration_bucket.name
}