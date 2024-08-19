# Creating a cloud function using the same bucket in which we stored the Serverless code for cloud function

# Cloud function will be triggred from the when the message is published to the pubsub from the webapp
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