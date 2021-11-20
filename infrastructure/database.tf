resource "google_sql_database" "lighthouse-database" {
  name     = "lighthouse"
  instance = google_sql_database_instance.lighthouse_database.name
}

resource "google_sql_database_instance" "lighthouse_database" {
  name             = "lighthouse-db-instance"
  region           = "europe-west3"
  database_version = "MYSQL_5_7"
  settings {
    tier = "db-f1-micro"

    ip_configuration {

      authorized_networks {
        
          name = "Default network"
          value = "0.0.0.0/0"

      }
    }
  }

}

resource "google_sql_user" "default" {
  name     = "root"
  instance = google_sql_database_instance.lighthouse_database.name
  password = "plschangeme"
}