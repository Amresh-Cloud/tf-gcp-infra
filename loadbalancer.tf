resource "google_compute_backend_service" "backend_service_lb" {
  name                  = var.backend_name
  load_balancing_scheme = var.lb_forwarding_schema
  health_checks         = [google_compute_health_check.vm_health_check.id]
  protocol              = var.backend_protocol
  session_affinity      = var.backend_session_affinity
  timeout_sec           = var.backend_timeout
  port_name             = var.backend_named_port
  backend {
    group           = google_compute_region_instance_group_manager.my_instance_group_manager.instance_group
    balancing_mode  = var.lb_balanced_mode
    capacity_scaler = 1.0
  }
  log_config {
    enable = var.lb_logs
    sample_rate = var.lb_log_rate
  }
}


resource "google_compute_url_map" "url_map_ld" {
  name            = var.url_mapping_name
  default_service = google_compute_backend_service.backend_service_lb.id
}


resource "google_compute_managed_ssl_certificate" "lb_default" {
  name    = var.ssl_certificate_name
  project = var.project_id

  managed {
    domains = var.domain_names
  }
}


resource "google_compute_target_https_proxy" "https_proxy" {
  name        = var.https_proxy_name
  description = var.https_proxy_description
  url_map     = google_compute_url_map.url_map_ld.id
  ssl_certificates = [
    google_compute_managed_ssl_certificate.lb_default.self_link
  ]

}
resource "google_compute_global_forwarding_rule" "https_forwarding_rule" {
  name                  = var.lb_forwarding_rule
  target                = google_compute_target_https_proxy.https_proxy.id
  ip_protocol           = var.forwarding_protocol
  load_balancing_scheme = var.lb_forwarding_schema
  port_range            = var.lb_forwarding_port
}