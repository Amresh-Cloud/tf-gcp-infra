resource "google_compute_health_check" "vm_health_check" {
  name                = var.health_checker_name
  check_interval_sec  = var.health_checker_time_check_interval
  timeout_sec         = var.health_checker_time_out
  healthy_threshold   = var.health_checker_healthy_vm_threshold
  unhealthy_threshold = var.health_checker_unhealthy_vm_threshold
  project             = var.project_id

  http_health_check {
    port               = var.health_checker_http_endpoint_port
    request_path       = var.health_checker_http_endpoint_path
    port_specification = var.health_checker_http_endpoint_port_speci
    proxy_header       = var.health_checker_http_endpoint_proxy_h

  }

}