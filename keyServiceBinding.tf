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





