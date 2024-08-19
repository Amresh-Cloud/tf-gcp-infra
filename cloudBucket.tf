# Creating a cloud Bucket to Store the Cloud Function (Serverless) Source Code

resource "google_storage_bucket" "cloud_bucket" {
  name     = var.bucket_name
  location = var.region
   encryption {
    default_kms_key_name = google_kms_crypto_key.storage_crypto_key.id
  }
  depends_on = [ google_kms_crypto_key.storage_crypto_key, google_kms_crypto_key_iam_binding.storage_crypto_key_binding ]
}
# Creating a Resoiurce to store the bucket Object using source code from Local
resource "google_storage_bucket_object" "archive" {
  name   = var.bucket_object_name
  bucket = google_storage_bucket.cloud_bucket.name
  source = var.bucket_source

}