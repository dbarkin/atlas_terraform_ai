# variables.tf: Input variables for the Terraform configuration

variable "mongodb_atlas_public_key" {
  description = "MongoDB Atlas API Public Key"
  type        = string
  sensitive   = true
}

variable "mongodb_atlas_private_key" {
  description = "MongoDB Atlas API Private Key"
  type        = string
  sensitive   = true
}

variable "mongodb_atlas_org_id" {
  description = "MongoDB Atlas Organization ID"
  type        = string
}

variable "mongodb_atlas_project_id" {
  description = "MongoDB Atlas Project ID"
  type        = string
}

variable "mongodb_atlas_cluster_size" {
  description = "MongoDB Atlas cluster size (e.g., M10, M20, etc.)"
  type        = string
  default     = "M10"
  validation {
    condition     = contains(["M10", "M20", "M30", "M40", "M50", "M60", "M80", "M140", "M200"], var.mongodb_atlas_cluster_size)
    error_message = "Valid values: M10, M20, M30, M40, M50, M60, M80, M140, M200."
  }
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Valid values: dev, staging, prod."
  }
}

variable "gcp_project_id" {
  description = "Google Cloud Platform Project ID"
  type        = string
}

variable "vpc_name" {
  description = "Name of the GCP VPC"
  type        = string
  default     = "default"
}

variable "vpc_cidr_block" {
  description = "CIDR block for GCP VPC access to MongoDB Atlas"
  type        = string
  default     = "10.0.1.0/24"  # Tighter default
}

variable "database_name" {
  description = "Name of the MongoDB database"
  type        = string
  default     = "application-db"
}

variable "num_shards" {
  description = "Number of shards for the MongoDB cluster"
  type        = number
  default     = 1
}