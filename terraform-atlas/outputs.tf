# outputs.tf: Outputs from the Terraform configuration

output "mongodb_connection_string" {
  description = "MongoDB connection string for private endpoint"
  value       = module.mongodb_cluster.connection_string
  sensitive   = true
}

output "mongodb_cluster_id" {
  description = "MongoDB Atlas Cluster ID"
  value       = module.mongodb_cluster.cluster_id
}

output "mongodb_private_endpoint" {
  description = "MongoDB Atlas Private Endpoint"
  value       = module.mongodb_network.private_endpoint_service_name
}