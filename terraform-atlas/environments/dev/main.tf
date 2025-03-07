# environments/dev/main.tf: Dev environment configuration

module "main" {
  source = "../../main.tf"
  
  mongodb_atlas_public_key  = var.mongodb_atlas_public_key
  mongodb_atlas_private_key = var.mongodb_atlas_private_key
  mongodb_atlas_org_id      = var.mongodb_atlas_org_id
  mongodb_atlas_project_id  = var.mongodb_atlas_project_id
  mongodb_atlas_cluster_size = var.mongodb_atlas_cluster_size
  environment               = "dev"
  gcp_project_id            = var.gcp_project_id
  vpc_name                  = var.vpc_name
  vpc_cidr_block            = var.vpc_cidr_block
  database_name             = var.database_name
  num_shards                = var.num_shards
}