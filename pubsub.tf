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