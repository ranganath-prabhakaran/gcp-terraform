resource "random_password" "password" {
  length  = 16
  special = true
}

resource "google_secret_manager_secret_version" "db_password_version" {
  secret      = var.db_password_secret_id
  secret_data = random_password.password.result
}

resource "google_sql_database_instance" "mysql_instance" {
  project          = var.project_id
  name             = "${var.prefix}-mysql-instance"
  region           = var.region
  database_version = "MYSQL_8_0"

  settings {
    tier = "db-n1-standard-2"
    disk_size = 20
    disk_type = "PD_SSD"
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_id
    }
    database_flags {
      name  = "log_bin"
      value = "on"
    }
    backup_configuration {
      enabled = true
    }
  }

  deletion_protection = false
  depends_on = [google_service_networking_connection.default] # Reference from parent module's networking
}

resource "google_sql_database" "database" {
  project  = var.project_id
  name     = var.db_name
  instance = google_sql_database_instance.mysql_instance.name
}

resource "google_sql_user" "user" {
  project  = var.project_id
  name     = var.db_user
  instance = google_sql_database_instance.mysql_instance.name
  password = random_password.password.result
  depends_on = [
    google_sql_database_instance.mysql_instance,
    google_secret_manager_secret_version.db_password_version
  ]
}