variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "region" {
  description = "The GCP region for resources."
  type        = string
  default     = "asia-south1"
}

variable "zone" {
  description = "The GCP zone for resources."
  type        = string
  default     = "asia-south1-a"
}

variable "prefix" {
  description = "A prefix for all created resources."
  type        = string
  default     = "agentic-mig"
}

variable "source_db_ip" {
  description = "The private IP address of the legacy source MySQL database."
  type        = string
}

variable "source_db_user" {
  description = "The username for the legacy source MySQL database."
  type        = string
  default     = "root"
}

variable "source_db_name" {
  description = "The name of the database to migrate from the source."
  type        = string
  default     = "employees"
}

variable "target_db_name" {
  description = "The name of the database to create in Cloud SQL."
  type        = string
  default     = "migrated_db"
}

variable "target_db_user" {
  description = "The name of the user to create in Cloud SQL."
  type        = string
  default     = "migrated_user"
}

variable "source_db_pass_secret_name" {
  description = "The name of the Secret Manager secret for the source DB password."
  type        = string
  default     = "source-db-password"
}

variable "cloud_sql_pass_secret_name" {
  description = "The name of the Secret Manager secret for the Cloud SQL user password."
  type        = string
  default     = "cloud-sql-password"
}