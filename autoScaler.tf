
# Creating a Instance Group Manager to manage Autoscaling

resource "google_compute_region_instance_group_manager" "my_instance_group_manager" {
  name   = var.group_manager_name
  region = var.region
  named_port {
    name = var.gorup_manager_named_port_name
    port = var.gorup_manager_named_port_port
  }
  version {
    instance_template = google_compute_region_instance_template.webapp_instance_template.id
    name              = var.group_manager_primary_version
  }
  base_instance_name = var.group_manager_basename

  auto_healing_policies {
    health_check      = google_compute_health_check.vm_health_check.id
    initial_delay_sec = 300
  }
}


# Creating a Autoscaler
resource "google_compute_region_autoscaler" "autoscaler-webapp" {
  name   = var.auto_scaler_name
  region = var.region
  target = google_compute_region_instance_group_manager.my_instance_group_manager.id

  autoscaling_policy {
    max_replicas    = var.auto_scaler_max
    min_replicas    = var.auto_scaler_min
    cooldown_period = var.auto_scaler_cooldown

    cpu_utilization {
      target = var.autoscaler_cpu_utilization
    }
  }
}