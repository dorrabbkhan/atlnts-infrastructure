data "archive_file" "btc_transfer" {
  type        = "zip"
  source_dir  = "./btc_transfer"
  output_path = "/tmp/btc-trans-function-${formatdate("YYMMDDhhmmss", timestamp())}.zip"
}

resource "google_storage_bucket" "function_storage" {
  name = "lighthouse-function"
  location="EU"

}

resource "google_storage_bucket" "images_storage" {
  name = "lighthouse-images-storage"
  location="EU"
}

data "google_iam_policy" "viewer" {
  binding {
    role = "roles/storage.objectViewer"
    members = [
        "allUsers",
    ] 
  }
}

resource "google_storage_bucket_iam_policy" "editor" {
  bucket = "${google_storage_bucket.images_storage.name}"
  policy_data = "${data.google_iam_policy.viewer.policy_data}"
}
resource "google_storage_bucket_object" "btc_transfer_zip" {
  # Append file MD5 to force bucket to be recreated
  name   = "btrans_source.zip#${data.archive_file.btc_transfer.output_md5}"
  bucket = google_storage_bucket.function_storage.name
  source = data.archive_file.btc_transfer.output_path
}

resource "google_project_service" "cf" {
  project = "nifty-saga-332620"
  service = "cloudfunctions.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = false
}

resource "google_project_service" "cb" {
  project = "nifty-saga-332620"
  service = "cloudbuild.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = false
}

resource "google_cloudfunctions_function" "transfer_btc_function" {
  name    = "btc_transfers"
  runtime = "python38" # Switch to a different runtime if needed

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.function_storage.name
  source_archive_object = google_storage_bucket_object.btc_transfer_zip.name
  trigger_http          = true
  entry_point           = "hello_world"
}

resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.transfer_btc_function.project
  region         = google_cloudfunctions_function.transfer_btc_function.region
  cloud_function = google_cloudfunctions_function.transfer_btc_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}