# modules/atlas-project/main.tf: Manages MongoDB Atlas project

resource "mongodbatlas_project" "project" {
  count      = var.project_id == "" ? 1 : 0
  org_id     = var.org_id
  name       = var.project_name
}

resource "mongodbatlas_federated_settings_identity_provider" "idp" {
  project_id = local.project_id
  name       = "google-cloud-idp"
  issuer_uri = "https://accounts.google.com"
  status     = "ACTIVE"
}

locals {
  project_id = var.project_id == "" ? mongodbatlas_project.project[0].id : var.project_id
}