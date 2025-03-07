# modules/atlas-cluster/variables.tf

variable "project_id" {
  description = "MongoDB Atlas Project ID"
  type        = string
}

variable "cluster_name" {
  description = "Name of the MongoDB Atlas cluster"
  type        = string
}

variable "cluster_size" {
  description = "MongoDB Atlas cluster size"
  type        = string
  default     = "M10"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "num_shards" {
  description = "Number of shards for the cluster"
  type        = number
  default     = 1
}