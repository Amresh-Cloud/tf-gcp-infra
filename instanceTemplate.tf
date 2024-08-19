
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
