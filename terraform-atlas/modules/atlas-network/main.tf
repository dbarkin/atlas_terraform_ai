# modules/atlas-network/main.tf: Configures networking for MongoDB Atlas

resource "mongodbatlas_project_ip_access_list" "ip_list" {
  project_id = var.project_id
  cidr_block = var.cidr_block  # Tighter CIDR
  comment    = "Allow GCP VPC subnet access"
}

resource "mongodbatlas_private_endpoint" "pe" {
  project_id    = var.project_id
  provider_name = "GCP"
  region        = var.region
}

resource "google_compute_address" "psc_endpoint_ip" {
  name         = "mongodb-psc-endpoint"
  subnetwork   = "default"
  address_type = "INTERNAL"
  region       = var.region
  project      = var.gcp_project_id
}

resource "google_compute_forwarding_rule" "psc_endpoint" {
  name                  = "mongodb-psc-forwarding-rule"
  region                = var.region
  project               = var.gcp_project_id
  target                = mongodbatlas_private_endpoint.pe.endpoint_service_name
  load_balancing_scheme = ""
  network               = var.vpc_name
  ip_address            = google_compute_address.psc_endpoint_ip.self_link
}

resource "mongodbatlas_private_endpoint_interface_link" "pe_link" {
  project_id            = var.project_id
  private_endpoint_id   = mongodbatlas_private_endpoint.pe.private_endpoint_id
  interface_endpoint_id = google_compute_forwarding_rule.psc_endpoint.psc_connection_id
  depends_on = [google_compute_forwarding_rule.psc_endpoint]
}