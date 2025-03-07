# modules/atlas-network/outputs.tf

output "private_endpoint_service_name" {
  description = "MongoDB Atlas Private Endpoint Service Name"
  value       = mongodbatlas_private_endpoint.pe.endpoint_service_name
}