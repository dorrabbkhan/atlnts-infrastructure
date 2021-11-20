data "archive_file" "handle_wallet" {
  type        = "zip"
  source_dir  = "./handle_wallet"
  output_path = "/tmp/handlew-function-${formatdate("YYMMDDhhmmss", timestamp())}.zip"
}

resource "google_storage_bucket_object" "wallet_zip" {
  # Append file MD5 to force bucket to be recreated
  name   = "handlew_source.zip#${data.archive_file.btc_transfer.output_md5}"
  bucket = google_storage_bucket.function_storage.name
  source = data.archive_file.handle_wallet.output_path
}

resource "google_cloudfunctions_function" "handle_wallets_function" {
  name    = "handle_wallets"
  runtime = "python38" # Switch to a different runtime if needed

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.function_storage.name
  source_archive_object = google_storage_bucket_object.wallet_zip.name
  trigger_http          = true
  entry_point           = "hello_world"

}

resource "google_cloudfunctions_function_iam_member" "handle_wallet_invoker" {
  project        = google_cloudfunctions_function.handle_wallets_function.project
  region         = google_cloudfunctions_function.handle_wallets_function.region
  cloud_function = google_cloudfunctions_function.handle_wallets_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}