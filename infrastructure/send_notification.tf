data "archive_file" "send_found_notifications" {
  type        = "zip"
  source_dir  = "./send_notification"
  output_path = "/tmp/sendns-function-${formatdate("YYMMDDhhmmss", timestamp())}.zip"
}

resource "google_storage_bucket_object" "notifications_zip" {
  # Append file MD5 to force bucket to be recreated
  name   = "sendn_source.zip#${data.archive_file.send_found_notifications.output_md5}"
  bucket = google_storage_bucket.function_storage.name
  source = data.archive_file.send_found_notifications.output_path
}

resource "google_cloudfunctions_function" "send_found_notifications_function" {
  name    = "send_found_notification"
  runtime = "python38" # Switch to a different runtime if needed

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.function_storage.name
  source_archive_object = google_storage_bucket_object.notifications_zip.name
  trigger_http          = true
  entry_point           = "hello_world"

  environment_variables = {
    "TWILIO_SID" = "AC443dabe36346738965256bd9e615646e"
    "TWILIO_AUTH_TOKEN" = "7cf1566a5c8c96320bd88e9455cb6ede"
    "TWILIO_MSG_SID" = "MGde8b60ed05990d0fe8930f1855965e99"
    "EMAIL_AUTH_TOKEN" = "dk_prod_1BX36287CE49X4JMHFNPRSABWTVJ"
    "EMAIL_EVENT" = "7Y3N4WVH79MEVQKXEJ1J1F2STPD8"
    "EMAIL_RECIPIENT" = "a7f343f3-0c77-486a-93e1-7936b7446fc5"
    "EMAIL_BRAND" = "T67479VZB8MZJANG10GWD4B3MTHP"

  }

}

resource "google_cloudfunctions_function_iam_member" "send_found_notifications_invoker" {
  project        = google_cloudfunctions_function.send_found_notifications_function.project
  region         = google_cloudfunctions_function.send_found_notifications_function.region
  cloud_function = google_cloudfunctions_function.send_found_notifications_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}