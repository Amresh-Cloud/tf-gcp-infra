resource "google_compute_network" "amresh" {
  name                            = var.vpc_network_name
  auto_create_subnetworks         = var.autocreate_subnet
  routing_mode                    = var.Routing_mode
  delete_default_routes_on_create = true
  project = var.project_id
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
  private_ip_google_access = true
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
# resource "google_compute_instance" "webapp_vm" {
#   name         = var.webapp_VM_Name
#   machine_type = var.machinetype
#   zone         = var.zone
#   tags         = var.tags
#   boot_disk {
#     initialize_params {
#       image = var.image
#       size  = var.disksize
#       type  = var.disktype
#     }
#   }
#   network_interface {
#     subnetwork = google_compute_subnetwork.webapp_subnet.self_link
#     access_config {
#       // Add access configuration if necessary
#     }
#   }
#   service_account {
#     email  = google_service_account.webapp_service_account.email
#     scopes = var.scope
#   }

#   depends_on              = [google_sql_database_instance.db_instance, google_service_account.webapp_service_account]
#   metadata_startup_script = <<-EOT
#     #!/bin/bash
#     if [ ! -f "/opt/webapp/.env" ]; then
#         touch /opt/webapp/.env
#     fi
#     echo "DBHOST=${google_sql_database_instance.db_instance.private_ip_address}" > /opt/webapp/.env
#     echo "DBUSER=webapp" >> /opt/webapp/.env
#     echo "DBPASSWORD=${random_password.webapp_db_password.result}" >> /opt/webapp/.env
#     echo "DBNAME=${var.DBNAME}" >> /opt/webapp/.env

#   EOT


# }
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
  rrdatas      = [google_compute_global_forwarding_rule.https_forwarding_rule.ip_address]
  depends_on   = [google_compute_global_forwarding_rule.https_forwarding_rule]
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
  location = var.region
   encryption {
    default_kms_key_name = google_kms_crypto_key.storage_crypto_key.id
  }
  depends_on = [ google_kms_crypto_key.storage_crypto_key, google_kms_crypto_key_iam_binding.storage_crypto_key_binding ]
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
  name        = var.cloud_function_name
  description = var.cloud_function_decription
  location    = var.region


  build_config {
    entry_point = var.cloud_function_entrypoint
    runtime     = var.cloud_function_runtinme
    source {
      storage_source {
        bucket = google_storage_bucket.cloud_bucket.name
        object = google_storage_bucket_object.archive.name
      }

    }
  }
  service_config {
    max_instance_count            = var.cloud_function_instance_count
    available_memory              = var.cloud_function_available_memory
    timeout_seconds               = var.cloud_function_timeout
    vpc_connector                 = google_vpc_access_connector.webapp_connector.name
    vpc_connector_egress_settings = var.cloud_function_vpc_engress
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
    retry_policy = var.cloud_function_event_retrypolicy
  }
  depends_on = [google_vpc_access_connector.webapp_connector]
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
resource "google_compute_region_instance_template" "webapp_instance_template" {
  name = var.insatnce_template_webapp
  disk {
    auto_delete  = var.insatnce_template_disk_autodelete
    boot         = var.instance_template_disk_boot
    device_name  = var.instance_template_disk_device
    mode         = var.instance_template_disk_mode
    source_image = var.image
    disk_size_gb = var.disksize
    type         = var.instance_template_disk_type
    disk_encryption_key{
      kms_key_self_link = google_kms_crypto_key.vm_crypto_key.id

    }
    
  }
 

  machine_type = var.instance_template_machine_type
  metadata = {
    startup-script = <<-EOT
    #!/bin/bash
    if [ ! -f "/opt/webapp/.env" ]; then
        touch /opt/webapp/.env
    fi
    echo "DBHOST=${google_sql_database_instance.db_instance.private_ip_address}" > /opt/webapp/.env
    echo "DBUSER=${var.DBNAME}" >> /opt/webapp/.env
    echo "DBPASSWORD=${random_password.webapp_db_password.result}" >> /opt/webapp/.env
    echo "DBNAME=${var.DBNAME}" >> /opt/webapp/.env

  EOT
  }
  network_interface {

    network    = google_compute_network.amresh.id
    subnetwork = google_compute_subnetwork.webapp_subnet.id
  }
  region = var.region

  service_account {
    
    email  = google_service_account.webapp_service_account.email
    scopes = var.scope
  }
  tags = var.webapp_instance_tags
}

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
# resource "google_compute_subnetwork" "load_balancer_sn" {
#   name                       = "backend-subnet"
#   ip_cidr_range              = "10.1.2.0/24"
#   network                    = google_compute_network.amresh.id
#   private_ipv6_google_access = "DISABLE_GOOGLE_ACCESS"
#   purpose                    = "PRIVATE"
#   region                     = var.region
#   stack_type                 = "IPV4_ONLY"
# }
# resource "google_compute_subnetwork" "proxy_only" {
#   name          = "proxy-only-subnet"
#   ip_cidr_range = "10.129.0.0/23"
#   network       = google_compute_network.amresh.id
#   purpose       = "REGIONAL_MANAGED_PROXY"
#   region        = var.region
#   role          = "ACTIVE"
# }

# resource "google_compute_firewall" "allow_proxy" {
#   name = "fw-allow-proxies"
#
#   allow {
#     ports    = ["2500"]
#     protocol = "tcp"
#   }
#   direction     = "INGRESS"
#   network       = google_compute_network.amresh.id
#   priority      = 1000

# }


# resource "google_compute_address" "default" {
#   name         = "gobal_address"
#   address_type = "EXTERNAL"
#   network_tier = "STANDARD"
# }

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

# resource "google_compute_region_target_http_proxy" "default" {
#   name    = "l7-xlb-proxy"
#   region  = var.region
#   url_map = google_compute_region_url_map.url_map_ld.id
# }
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

# resource "google_compute_forwarding_rule" "default" {
#   name       = "l7-xlb-forwarding-rule"
#   provider   = google-beta
#   depends_on = [google_compute_subnetwork.proxy_only]
#   region     = var.region

#   ip_protocol           = "TCP"
#   load_balancing_scheme = "EXTERNAL_MANAGED"
#   port_range            = "80"
#   target                = google_compute_region_target_http_proxy.default.id
#   network               = google_compute_network.default.id
#   ip_address            = google_compute_address.default.id
#   network_tier          = "STANDARD"
# }
resource "google_kms_key_ring" "my_key_ring" {
  name     = "${random_string.random_string_vmkey.result}"
  project = var.project_id
  location = var.region
}

resource "random_string" "random_string_vmkey" {
  length  = 5
  special = false
}
resource "google_kms_crypto_key" "vm_crypto_key" {
  name = "instance-key${random_string.random_string_vmkey.result}"
  key_ring        = google_kms_key_ring.my_key_ring.id
  rotation_period = var.key_rotation
 
  purpose  = var.key_purpose
   lifecycle {
    prevent_destroy = false
  }

}


resource "google_kms_crypto_key" "storage_crypto_key" {
  name            = var.storage_key_name
  key_ring        = google_kms_key_ring.my_key_ring.id
  rotation_period = var.key_rotation
  purpose  = var.key_purpose
   lifecycle {
    prevent_destroy = false
  }

}
resource "google_kms_crypto_key" "sql_instance_key" {
  name     = var.sql_instance_key_name
  key_ring = google_kms_key_ring.my_key_ring.id
  purpose  = var.key_purpose
  rotation_period = var.key_rotation
   lifecycle {
    prevent_destroy = false
  }

}
# data "google_project" "current" {
# }
# locals {
#     cloud_storage_service_account = "service-devv-414701@gs-project-accounts.iam.gserviceaccount.com"
# }


# resource "google_service_account" "keychain_service_account" {
#   account_id   = var.keychain_sql_serviceAccount
#   display_name = var.keychain_sql_serviceAccount_des
#   project      = var.project_id
# }
resource "google_project_service_identity" "gcp_sa_cloud_sql" {
  provider = google-beta
  project = var.project_id
  service  = "sqladmin.googleapis.com"
}
resource "google_kms_crypto_key_iam_binding" "sql_crypto_key_binding" {

  crypto_key_id = google_kms_crypto_key.sql_instance_key.id
   role    = var.keychain_sql_serviceAccount_role

  members = [
     "serviceAccount:${google_project_service_identity.gcp_sa_cloud_sql.email}",
  ]
  depends_on = [ google_kms_crypto_key.sql_instance_key ]
}
resource "google_kms_crypto_key_iam_binding" "vm_crypto_key_binding" {
  
  crypto_key_id = google_kms_crypto_key.vm_crypto_key.id
   role    = var.keychain_sql_serviceAccount_role

  members = [
     var.vm_member_email
  ]
  depends_on = [ google_kms_crypto_key.vm_crypto_key ]
}
resource "google_kms_crypto_key_iam_binding" "storage_crypto_key_binding" {
 
  crypto_key_id = google_kms_crypto_key.storage_crypto_key.id
   role    = var.keychain_sql_serviceAccount_role

  members = [
     var.stroage_member_email
  ]
  depends_on = [ google_kms_crypto_key.storage_crypto_key ]
}




