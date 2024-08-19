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