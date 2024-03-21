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
  name = var.block_ssh
  network = google_compute_network.amresh.name
  deny {
    protocol = var.protocol
    ports= var.disable_port
  }
  source_ranges = var.source_ranges
}
resource "google_compute_firewall" "enabled_http" {
  name = var.enabled_http
  network = google_compute_network.amresh.name

  allow {
    protocol = var.protocol
    ports = var.port_allowed
  }

  source_ranges = var.source_ranges
  target_tags = var.target_tags
}
resource "google_compute_instance" "webapp_vm" {
  name          = var.webapp_VM_Name
  machine_type  = var.machinetype
  zone          = var.zone
  tags          = var.tags
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
      // Add access configuration if necessary
    }
  }
  service_account {
    email  = google_service_account.webapp_service_account.email
    scopes = var.scope
  }
  
 depends_on   = [google_sql_database_instance.db_instance, google_service_account.webapp_service_account]
  metadata_startup_script = <<-EOT
    #!/bin/bash
    if [ ! -f "/opt/webapp/.env" ]; then
        touch /opt/webapp/.env
    fi
    echo "DBHOST=${google_sql_database_instance.db_instance.private_ip_address}" > /opt/webapp/.env
    echo "DBUSER=webapp" >> /opt/webapp/.env
    echo "DBPASSWORD=${random_password.webapp_db_password.result}" >> /opt/webapp/.env
    echo "DBNAME=${var.DBNAME}" >> /opt/webapp/.env

  EOT

  
}
resource "google_project_service" "service_networking" {
  service = "servicenetworking.googleapis.com"
}

resource "google_compute_global_address" "default" {
  project       = google_compute_network.amresh.project
  name          = var.global_address_name
  address_type  = var.global_address_type
  purpose       = var.global_address_purpose
  network       = google_compute_network.amresh.id
  prefix_length = var.global_prefix_length
}
resource "google_service_networking_connection" "private_connection" {
  network                 = google_compute_network.amresh.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.default.name]
}
resource "google_sql_database_instance" "db_instance" {
  name             = var.web_dbname
  database_version = var.db_version
  region           = var.region
  depends_on       = [google_service_networking_connection.private_connection]


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

resource "google_sql_database" "webapp_db" {
  name     = var.database_name
  instance = google_sql_database_instance.db_instance.name
}

resource "random_password" "webapp_db_password" {
  special = var.database_pass_special
  length  = var.database_pass_length
}

resource "google_sql_user" "webapp_user" {
  name     = var.database_name
  instance = google_sql_database_instance.db_instance.name
  password = random_password.webapp_db_password.result
}
resource "google_dns_record_set" "webapp_dns" {
  name         = var.dns_name
  type         = var.dns_type
  ttl          = var.dns_ttl
  managed_zone = var.dns_managed_zone
  rrdatas      = [google_compute_instance.webapp_vm.network_interface.0.access_config.0.nat_ip]
  depends_on = [google_compute_instance.webapp_vm]
}

resource "google_service_account" "webapp_service_account" {
  account_id   = var.account_id
  display_name = var.display_name
  project      = var.project_id
}

resource "google_project_iam_binding" "log_admin" {
  project = var.project_id
  role    = var.log_role
  members = [
    "serviceAccount:${google_service_account.webapp_service_account.email}",
  ]
}

resource "google_project_iam_binding" "monitor_writer" {
  project = var.project_id
  role    = var.monitor_role
  members = [
    "serviceAccount:${google_service_account.webapp_service_account.email}",
  ]
}



