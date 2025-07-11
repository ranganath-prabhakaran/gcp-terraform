# /terraform/kms.tf

# This ensures the Cloud SQL service agent exists before we grant it permissions
resource "google_project_service_identity" "sql_sa" {
  provider = google-beta
  project  = var.project_id
  service  = "sqladmin.googleapis.com"
}

# A KMS key ring to hold the encryption key
resource "google_kms_key_ring" "db_key_ring" {
  project  = var.project_id
  name     = "${var.prefix}-db-keyring"
  location = var.region
}

# The KMS key for encrypting the Cloud SQL instance
resource "google_kms_crypto_key" "db_key" {
  name     = "${var.prefix}-db-key"
  key_ring = google_kms_key_ring.db_key_ring.id
  purpose  = "ENCRYPT_DECRYPT"
}

# Grant the Cloud SQL service agent permission to use the new key
resource "google_kms_crypto_key_iam_member" "sql_sa_encrypt" {
  crypto_key_id = google_kms_crypto_key.db_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_project_service_identity.sql_sa.email}"
}
