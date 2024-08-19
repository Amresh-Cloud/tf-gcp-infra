# Creating a Google sql Instance which will be used by all the deployed Virtual Machines and Cloud Function
resource "google_sql_database_instance" "db_instance" {
  name             = var.web_dbname
  database_version = var.db_version
  region           = var.region
  depends_on       = [google_service_networking_connection.private_connection,google_kms_crypto_key.sql_instance_key]
  encryption_key_name = google_kms_crypto_key.sql_instance_key.id


  settings {
    tier              = var.db_tier
    availability_type = var.db_availability
    disk_type         = var.db_disktype
    disk_autoresize   = var.db_disk_resize
    disk_size         = var.db_disk_size

   

    backup_configuration {
      enabled            = var.db_backup_enable
      binary_log_enabled = var.db_binary_log
    }

    ip_configuration {
      ipv4_enabled    = var.db_ipv4_enable
      private_network = google_compute_network.amresh.self_link
    }
  }

  deletion_protection = false
}


# Creating a database for the webapp which will be used by all the deployed Web Application Instances
resource "google_sql_database" "webapp_db" {
  name     = var.database_name
  instance = google_sql_database_instance.db_instance.name
}

#Creating a Sql User which will be used by the Web Application
resource "google_sql_user" "webapp_user" {
  name     = var.database_name
  instance = google_sql_database_instance.db_instance.name
  password = random_password.webapp_db_password.result
}
# Creating a Random Password which will be used for connecting to the sql Instance
resource "random_password" "webapp_db_password" {
  special = var.database_pass_special
  length  = var.database_pass_length
}
