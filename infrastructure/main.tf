provider "google" {
  project = "nifty-saga-332620"
  region  = "europe-west3"
  zone    = "europe-west3-a"
}

resource "google_compute_project_metadata" "default" {
  metadata = {
    "serial-port-enable" = true
  }
}

resource "google_compute_instance" "backend-api" {
  name         = "backend-api-machine"
  machine_type = "f1-micro"
  can_ip_forward = true

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  metadata = {
    ssh-keys = "${file("./keys")}"
  }

  metadata_startup_script = "${file("../infrastructure/startup_script.sh")}"

  network_interface {
    # A default network is created for all GCP projects
    network = "default"
    access_config {
    }
  }
}

resource "google_app_engine_application" "app" {
  project     = "nifty-saga-332620"
  location_id = "europe-west3"
}