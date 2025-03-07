# modules/atlas-project/outputs.tf

output "project_id" {
  description = "MongoDB Atlas Project ID"
  value       = local.project_id
}