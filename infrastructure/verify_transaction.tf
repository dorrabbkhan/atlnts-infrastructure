data "archive_file" "verify_transaction" {
  type        = "zip"
  source_dir  = "./verify_transaction"
  output_path = "/tmp/verify-function-${formatdate("YYMMDDhhmmss", timestamp())}.zip"
}

resource "google_storage_bucket_object" "verify_zip" {
  # Append file MD5 to force bucket to be recreated
  name   = "verify_source.zip#${data.archive_file.verify_transaction.output_md5}"
  bucket = google_storage_bucket.function_storage.name
  source = data.archive_file.verify_transaction.output_path
}

resource "google_cloudfunctions_function" "verify_transaction_function" {
  name    = "verify_transaction"
  runtime = "python38" # Switch to a different runtime if needed

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.function_storage.name
  source_archive_object = google_storage_bucket_object.verify_zip.name
  trigger_http          = true
  entry_point           = "hello_world"

}

resource "google_cloudfunctions_function_iam_member" "verify_transaction_invoker" {
  project        = google_cloudfunctions_function.verify_transaction_function.project
  region         = google_cloudfunctions_function.verify_transaction_function.region
  cloud_function = google_cloudfunctions_function.verify_transaction_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}