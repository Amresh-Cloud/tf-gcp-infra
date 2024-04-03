resource "google_compute_network" "amresh" {
  name                            = var.vpc_network_name
  auto_create_subnetworks         = var.autocreate_subnet
  routing_mode                    = var.Routing_mode
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
resource "google_compute_instance" "webapp_vm" {
  name         = var.webapp_VM_Name
  machine_type = var.machinetype
  zone         = var.zone
  tags         = var.tags
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

  depends_on              = [google_sql_database_instance.db_instance, google_service_account.webapp_service_account]
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
  depends_on   = [google_compute_instance.webapp_vm]
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

resource "google_project_iam_binding" "pubsub" {
  project = var.project_id
  role    = var.pubsub_role
  members = [
    "serviceAccount:${google_service_account.webapp_service_account.email}",
  ]
}

resource "google_pubsub_topic" "webapp_topic" {
  name = var.pubsub_topic_name
}

resource "google_pubsub_subscription" "webapp_subscription" {
  name                       = var.pubsub_subscription_name
  topic                      = google_pubsub_topic.webapp_topic.name
  message_retention_duration = var.message_duration
  ack_deadline_seconds       = var.ack_seconds
  expiration_policy {
    ttl = var.sub_expire
  }
}
resource "google_storage_bucket" "cloud_bucket" {
  name     = var.bucket_name
  location = var.bucket_location
}
resource "google_storage_bucket_object" "archive" {
  name   = var.bucket_object_name
  bucket = google_storage_bucket.cloud_bucket.name
  source = var.bucket_source
}
resource "google_pubsub_subscription_iam_binding" "webapp_subscription_binding" {
  project      = var.project_id
  subscription = google_pubsub_subscription.webapp_subscription.name
  role         = var.pubsub_sub_bind
  members      = var.subscription_members
}
resource "google_project_service" "serverless_vpc_access" {
  service = "vpcaccess.googleapis.com"
}

resource "google_vpc_access_connector" "webapp_connector" {
  name          = var.serverless_connector_name
  region        = var.region
  network       = google_compute_network.amresh.self_link
  ip_cidr_range = var.connector_ipcidr
  min_instances = var.min_no
  max_instances = var.max_no
  machine_type  = var.variable_machinetype

  depends_on = [google_project_service.serverless_vpc_access]
}
resource "google_cloudfunctions2_function" "function" {
  name        = "my-cloud-function"
  description = "My Cloud Function"
  location    = var.region


  build_config {
    entry_point = "sendemail"
    runtime     = "nodejs18"
    source {
      storage_source {
        bucket = google_storage_bucket.cloud_bucket.name
        object = google_storage_bucket_object.archive.name
      }

    }
  }
  service_config {
    max_instance_count            = 1
    available_memory              = "256M"
    timeout_seconds               = "60"
    vpc_connector                 = google_vpc_access_connector.webapp_connector.name
    vpc_connector_egress_settings = "PRIVATE_RANGES_ONLY"
    environment_variables = {
      MAILGUN_API_KEY = var.mailgun_api_key
      DOMAIN_NAME     = var.domain_name
      DBUSER          = "${var.DBNAME}"
      DBNAME          = "${var.DBNAME}"
      DBHOST          = "${google_sql_database_instance.db_instance.private_ip_address}"
      DBPASSWORD      = "${random_password.webapp_db_password.result}"

    }
  }
  event_trigger {
    trigger_region = var.region

    event_type   = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic = google_pubsub_topic.webapp_topic.id
    retry_policy = "RETRY_POLICY_RETRY"
  }
  depends_on = [google_vpc_access_connector.webapp_connector]
}


resource "google_compute_firewall" "firewall_health_check" {
  name = "fw-allow-health-check"
  allow {
    protocol = "tcp"
    ports=["2500"]
  }
  direction     = "INGRESS"
  network       = google_compute_network.amresh.self_link
  priority      = 1000
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["load-balanced-backend"]
}

resource "google_compute_region_health_check" "vm_health_check" {
  name               = "my-health-check"
  check_interval_sec = 30
  timeout_sec        = 10
  healthy_threshold  = 2
  unhealthy_threshold= 2
  region = var.region
  project = var.project_id

  http_health_check {
    port = "2500"
    request_path = "/healthz"
    port_specification = "USE_FIXED_PORT"
    proxy_header       = "NONE"

  }

}
resource "google_compute_region_instance_template" "webapp_instance_template" {
  name = "l7-xlb-backend-template"
  disk {
    auto_delete  = true
    boot         = true
    device_name  = "persistent-disk-0"
    mode         = "READ_WRITE"
    source_image = var.image
    disk_size_gb=var.disksize
    type         = "PERSISTENT"
  }

  machine_type = "n1-standard-1"
  metadata = {
    startup-script = <<-EOT
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
  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }
    network    = google_compute_network.amresh.id
    subnetwork = google_compute_subnetwork.webapp_subnet.id
  }
  region = var.region

  service_account {
    email  = google_service_account.webapp_service_account.email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/pubsub", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  }
  tags = ["load-balanced-backend","allow-health-check","http-server"]
}

resource "google_compute_region_instance_group_manager" "my_instance_group_manager" {
  name = "l7-xlb-backend-example"
  region = var.region
  named_port {
    name = "http"
    port = 2500
  }
  version {
    instance_template = google_compute_region_instance_template.webapp_instance_template.id
    name              = "primary"
  }
  base_instance_name = "vm"

  auto_healing_policies {
    health_check      = google_compute_region_health_check.vm_health_check.id
    initial_delay_sec = 300
  }
}
resource "google_compute_region_autoscaler" "autoscaler-webapp" {
  name   = "my-region-autoscaler"
  region = var.region
  target = google_compute_region_instance_group_manager.my_instance_group_manager.id

  autoscaling_policy {
    max_replicas    = 2
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.05
    }
  }
}



