# main.tf: Root configuration for MongoDB Atlas on GCP

terraform {
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.12.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  backend "gcs" {
    bucket = "mongodb-atlas-tf-state"
    prefix = "terraform/state"
  }
}

provider "mongodbatlas" {
  public_key  = var.mongodb_atlas_public_key
  private_key = var.mongodb_atlas_private_key
}

provider "google" {
  project = var.gcp_project_id
  region  = "northamerica-northeast2"
}

module "mongodb_project" {
  source = "./modules/atlas-project"
  
  org_id       = var.mongodb_atlas_org_id
  project_id   = var.mongodb_atlas_project_id
  project_name = "${var.environment}-mongodb-project"
}

module "mongodb_cluster" {
  source = "./modules/atlas-cluster"
  
  project_id      = module.mongodb_project.project_id
  cluster_name    = "${var.environment}-mongodb-cluster"
  cluster_size    = var.mongodb_atlas_cluster_size
  environment     = var.environment
  num_shards      = var.num_shards  # Added for scalability
}

module "mongodb_users" {
  source = "./modules/atlas-user"
  
  project_id      = module.mongodb_project.project_id
  cluster_name    = module.mongodb_cluster.cluster_name
  database_name   = var.database_name
}

module "mongodb_network" {
  source = "./modules/atlas-network"
  
  project_id      = module.mongodb_project.project_id
  gcp_project_id  = var.gcp_project_id
  vpc_name        = var.vpc_name
  region          = "northamerica-northeast2"
  cidr_block      = var.vpc_cidr_block  # Tightened CIDR
}