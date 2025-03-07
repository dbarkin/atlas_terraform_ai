# modules/atlas-user/variables.tf

variable "project_id" {
  description = "MongoDB Atlas Project ID"
  type        = string
}

variable "cluster_name" {
  description = "MongoDB Atlas Cluster Name"
  type        = string
}

variable "database_name" {
  description = "Name of the MongoDB database"
  type        = string
}