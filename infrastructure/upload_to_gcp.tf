data "archive_file" "upload_to_gcp" {
  type        = "zip"
  source_dir  = "./upload_to_gcp"
  output_path = "/tmp/upload-function-${formatdate("YYMMDDhhmmss", timestamp())}.zip"
}

resource "google_storage_bucket_object" "upload_zip" {
  # Append file MD5 to force bucket to be recreated
  name   = "upload_source.zip#${data.archive_file.upload_to_gcp.output_md5}"
  bucket = google_storage_bucket.function_storage.name
  source = data.archive_file.upload_to_gcp.output_path
}

resource "google_cloudfunctions_function" "upload_to_gcp_function" {
  name    = "upload_to_gcp"
  runtime = "python38" # Switch to a different runtime if needed

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.function_storage.name
  source_archive_object = google_storage_bucket_object.upload_zip.name
  trigger_http          = true
  entry_point           = "hello_world"

}

resource "google_cloudfunctions_function_iam_member" "upload_to_gcp_invoker" {
  project        = google_cloudfunctions_function.upload_to_gcp_function.project
  region         = google_cloudfunctions_function.upload_to_gcp_function.region
  cloud_function = google_cloudfunctions_function.upload_to_gcp_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}