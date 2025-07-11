# terraform/main.tf
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.43"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.12"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

module "networking" {
  source       = "./modules/networking"
  project_id   = var.project_id
  region       = var.region
  network_name = "${var.prefix}-vpc"
  subnet_name  = "${var.prefix}-subnet"
  subnet_cidr  = "10.10.0.0/16"
}

module "iam_secrets" {
  source           = "./modules/iam_secrets"
  project_id       = var.project_id
  prefix           = var.prefix
  source_db_pass_secret_name = var.source_db_pass_secret_name
  cloud_sql_pass_secret_name = var.cloud_sql_pass_secret_name
}

module "gce_mcp_server" {
  source           = "./modules/gce_mcp_server"
  project_id       = var.project_id
  region           = var.region
  zone             = var.zone
  prefix           = var.prefix
  network_name     = module.networking.network_name
  subnet_name      = module.networking.subnet_name
  service_account_email = module.iam_secrets.service_account_email
  source_db_ip     = var.source_db_ip
  source_db_user   = var.source_db_user
  source_db_name   = var.source_db_name
  source_db_pass_secret_id = module.iam_secrets.source_db_pass_secret_id
  depends_on       = [module.networking, module.iam_secrets]
}

module "cloud_sql" {
  source           = "./modules/cloud_sql"
  project_id       = var.project_id
  region           = var.region
  prefix           = var.prefix
  network_id       = module.networking.network_id
  db_name          = var.target_db_name
  db_user          = var.target_db_user
  db_password_secret_id = module.iam_secrets.cloud_sql_password_secret_id
  depends_on       = [module.networking, module.iam_secrets]
}