resource "google_compute_firewall" "blocking_ssh" {
  name    = var.block_ssh
  network = google_compute_network.amresh.name
  deny {
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

resource "google_compute_firewall" "firewall_health_check" {
  name = var.health_firewall_name
  allow {
    protocol = var.health_fire_protocol
    ports    = var.health_fire_ports
  }
  direction     = var.health_fire_direction
  network       = google_compute_network.amresh.self_link
  priority      = var.health_fire_priority
  source_ranges = var.health_fire_source_range
  target_tags   = var.health_fire_target_tags
}