resource "google_storage_bucket" "migration_bucket" {
  project      = var.project_id
  name         = "${var.prefix}-migration-bucket-${var.project_id}"
  location     = var.region
  force_destroy = true
}

resource "google_compute_instance" "mcp_server" {
  project      = var.project_id
  name         = "${var.prefix}-mcp-server"
  machine_type = "e2-medium"
  zone         = var.zone
  tags         = ["allow-ssh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = var.network_name
    subnetwork = var.subnet_name
    # No access_config block means no public IP
  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = templatefile("../scripts/setup_mcp_server.sh", {
    source_db_ip   = var.source_db_ip,
    source_db_user = var.source_db_user,
    source_db_name = var.source_db_name,
    source_db_pass_secret_id = var.source_db_pass_secret_id,
    project_id     = var.project_id
  })

  allow_stopping_for_update = true
  depends_on = [
    google_storage_bucket.migration_bucket
  ]
}