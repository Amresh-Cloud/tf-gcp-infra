resource "google_compute_network" "amresh" {
  name                    = var.vpc_network_name
  auto_create_subnetworks = var.autocreate_subnet
  routing_mode            = var.Routing_mode
  delete_default_routes_on_create = true
}

resource "google_compute_subnetwork" "webapp_subnet" {
  name          = var.webapp_subnet_name
  ip_cidr_range = var.webapp_subnet_cidr
  region        = var.region
  network       = google_compute_network.amresh.id
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "db_subnet" {
  name          = var.db_subnet_name
  ip_cidr_range = var.db_subnet_cidr
  region        = var.region
  network       = google_compute_network.amresh.id
}

resource "google_compute_route" "webapp_internet_route" {
  name             = var.webapp_internet_route
  dest_range       = var.dest_range
  network          = google_compute_network.amresh.id
  next_hop_gateway = var.next_hop_gateway_default
}


resource "google_compute_firewall" "blocking_ssh" {
  name    = var.block_ssh
  network = google_compute_network.amresh.name

  allow {
    protocol = var.protocol
    ports    = var.disable_port
  }

  source_ranges = var.source_ranges
}

resource "google_compute_firewall" "enabled_http" {
  name    = var.enabled_http
  network = google_compute_network.amresh.name

  allow {
    protocol = var.protocol
    ports    = var.port_allowed
  }

  source_ranges = var.source_ranges
  target_tags   = var.target_tags
}

resource "google_project_service" "service_networking" {
  service = "servicenetworking.googleapis.com"
}

resource "google_compute_global_address" "default" {
  project      = google_compute_network.amresh.project
  name         = "global-psconnect-ip"
  address_type = "INTERNAL"
  purpose      = "VPC_PEERING"
  network      = google_compute_network.amresh.id
  prefix_length = 24
}
resource "google_service_networking_connection" "private_connection" {
  network                 = google_compute_network.amresh.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.default.name]
}


resource "google_sql_database_instance" "webapp_db_instance" {
  name             = "webmsql"
  database_version = "MYSQL_8_0"
  region           = var.region
  depends_on       = [google_service_networking_connection.private_connection]
  

  settings {
    tier              = "db-f1-micro"
    disk_autoresize   = true
    disk_size         = 10
    disk_type         = "pd-ssd"
    availability_type = "REGIONAL"

    backup_configuration {
      enabled = true
      binary_log_enabled = true
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.amresh.self_link
    }
  }

  deletion_protection = false
}

resource "google_sql_database" "webapp_db" {
  name     = "webapp"
  instance = google_sql_database_instance.webapp_db_instance.name
}

resource "random_password" "webapp_db_password" {
  length  = 16
  special = true
}

resource "google_sql_user" "webapp_user" {
  name     = "webapp"
  instance = google_sql_database_instance.webapp_db_instance.name
  password = random_password.webapp_db_password.result
}
resource "google_compute_instance" "webapp_vm" {
  name         = var.webapp_VM_Name
  machine_type = var.machinetype
  zone         = var.zone
  tags         = var.tags
  depends_on = [ google_service_networking_connection.private_connection ]

  boot_disk {
    initialize_params {
      image = var.image
      size  = var.disksize
      type  = var.disktype
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.webapp_subnet.self_link
    access_config {
      
    }
   
  }

 


metadata_startup_script = <<-EOT
    #!/bin/bash
    if [ ! -f "/opt/webapp/.env" ]; then
        touch /opt/webapp/.env
    fi
    echo "DBHOST=${google_sql_database_instance.webapp_db_instance.first_ip_address}" > /opt/webapp/.env
    echo "DBUSER=webapp" >> /opt/webapp/.env
    echo "DBPASSWORD=${random_password.webapp_db_password.result}" >> /opt/webapp/.env
    echo "DBNAME=webapp" >> /opt/webapp/.env

  EOT

  service_account {
    email  = var.service_email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  
}


