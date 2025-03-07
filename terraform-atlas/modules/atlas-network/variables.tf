# modules/atlas-network/variables.tf

variable "project_id" {
  description = "MongoDB Atlas Project ID"
  type        = string
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

variable "region" {
  description = "GCP Region for the private endpoint"
  type        = string
  default     = "northamerica-northeast2"
}

variable "cidr_block" {
  description = "CIDR block for GCP VPC access"
  type        = string
  default     = "10.0.1.0/24"
}