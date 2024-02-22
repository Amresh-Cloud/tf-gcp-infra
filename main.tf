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
    email  = var.service_email
    scopes = var.scope
  }
}
