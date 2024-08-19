resource "google_pubsub_subscription_iam_binding" "webapp_subscription_binding" {
  project      = var.project_id
  subscription = google_pubsub_subscription.webapp_subscription.name
  role         = var.pubsub_sub_bind
  members      = var.subscription_members
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