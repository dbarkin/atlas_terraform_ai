# modules/atlas-project/variables.tf

variable "org_id" {
  description = "MongoDB Atlas Organization ID"
  type        = string
}

variable "project_id" {
  description = "MongoDB Atlas Project ID (empty to create new)"
  type        = string
  default     = ""
}

variable "project_name" {
  description = "Name of the MongoDB Atlas project"
  type        = string
}