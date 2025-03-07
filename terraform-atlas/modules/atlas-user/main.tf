# modules/atlas-user/main.tf: Manages MongoDB Atlas database users

resource "random_password" "password" {
  length  = 16
  special = true
  upper   = true
  lower   = true
  numeric = true
}

resource "mongodbatlas_database_user" "db_user" {
  project_id         = var.project_id
  username           = "app-user"
  password           = random_password.password.result
  auth_database_name = "admin"
  
  roles {
    role_name     = "readWrite"
    database_name = var.database_name
  }
  
  scopes {
    name = var.cluster_name
    type = "CLUSTER"
  }
}

resource "google_secret_manager_secret" "db_password" {
  secret_id = "mongodb-${var.cluster_name}-password"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "db_password_version" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.password.result
}