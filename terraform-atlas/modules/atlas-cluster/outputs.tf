# modules/atlas-cluster/outputs.tf

output "cluster_id" {
  description = "MongoDB Atlas Cluster ID"
  value       = mongodbatlas_cluster.cluster.cluster_id
}

output "cluster_name" {
  description = "MongoDB Atlas Cluster Name"
  value       = mongodbatlas_cluster.cluster.name
}

output "connection_string" {
  description = "MongoDB Atlas Connection String"
  value       = mongodbatlas_cluster.cluster.connection_strings[0].private_endpoint[0].srv_connection_string
  sensitive   = true
}