# modules/atlas-cluster/main.tf: Configures MongoDB Atlas cluster

resource "mongodbatlas_cluster" "cluster" {
  project_id                  = var.project_id
  name                        = var.cluster_name
  provider_name               = "GCP"
  provider_instance_size_name = var.cluster_size
  provider_region_name        = "NORTH_AMERICA_NORTHEAST_2"
  
  num_shards = var.num_shards  # Parameterized for scalability
  
  replication_specs {
    num_shards = var.num_shards
    
    regions_config {
      region_name     = "NORTH_AMERICA_NORTHEAST_2"
      electable_nodes = 2
      priority        = 7
      read_only_nodes = 0
    }
    
    regions_config {
      region_name     = "NORTH_AMERICA_NORTHEAST_1"
      electable_nodes = 1
      priority        = 6
      read_only_nodes = 0
    }
  }

  backup_enabled               = true
  pit_enabled                  = true  # Point-in-time recovery for RPO
  provider_backup_enabled      = true
  auto_scaling_disk_gb_enabled = true

  cloud_backup {
    point_in_time_window_hours = 24  # Extensible to 7 days via Atlas
  }
}