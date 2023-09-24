resource "google_compute_instance" "test1" {
  project      = var.project_id
  zone         = "europe-north1-b"
  name         = "test1"
  machine_type = "e2-small"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network    = google_compute_network.mestari.id
    subnetwork = google_compute_subnetwork.mestari.id
  }
}

resource "google_compute_instance" "derp1" {
  project      = var.project_id
  zone         = "europe-north1-b"
  name         = "derp1"
  machine_type = "e2-small"
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }
  network_interface {
    network    = google_compute_network.mestari.id
    subnetwork = google_compute_subnetwork.mestari.id
    access_config {
      nat_ip = google_compute_address.derp1_public.address
    }
  }
}

resource "google_compute_instance_group" "derp" {
  name        = "derp-servers"
  description = "derp servers"
  zone        = "europe-north1-b"

  instances = [
    google_compute_instance.derp1.id,
  ]

  named_port {
    name = "http"
    port = "80"
  }

  named_port {
    name = "https"
    port = "443"
  }

  named_port {
    name = "stun"
    port = "3478"
  }
}
