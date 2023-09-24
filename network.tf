resource "google_compute_network" "mestari" {
  name                    = "mestarivpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "mestari" {
  name          = "mestari"
  ip_cidr_range = "10.56.0.0/16"
  region        = var.region
  network       = google_compute_network.mestari.id
}

resource "google_compute_address" "derp_lb" {
  name         = "derp-lb"
  region       = var.region
  address_type = "EXTERNAL"
}

resource "google_compute_address" "mestari_nat" {
  name         = "mestari-nat"
  region       = var.region
  address_type = "EXTERNAL"
}

# resource "google_compute_address" "derp1_public" {
#   name         = "derp1"
#   region       = var.region
#   address_type = "EXTERNAL"
# }

resource "google_compute_router" "mestari" {
  project = var.project_id
  name    = "mestari-router"
  network = google_compute_network.mestari.id
  region  = var.region
}

resource "google_compute_router_nat" "mestari" {
  name                               = "mestari-nat"
  router                             = google_compute_router.mestari.name
  region                             = var.region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.mestari_nat.self_link]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_firewall" "icmp" {
  project = var.project_id
  name    = "allow-icmp"
  network = google_compute_network.mestari.id

  allow {
    protocol = "icmp"
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "iap_ssh" {
  project = var.project_id
  name    = "allow-iap-ssh"
  network = google_compute_network.mestari.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_firewall" "http" {
  project = var.project_id
  name    = "allow-http"
  network = google_compute_network.mestari.id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "https" {
  project = var.project_id
  name    = "allow-https"
  network = google_compute_network.mestari.id

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "stun" {
  project = var.project_id
  name    = "allow-stun"
  network = google_compute_network.mestari.id

  allow {
    protocol = "udp"
    ports    = ["3478"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "lb_health_check" {
  project = var.project_id
  name    = "lb-health-check"
  network = google_compute_network.mestari.id

  allow {
    protocol = "tcp"
  }
  source_ranges = ["35.191.0.0/16", "209.85.152.0/22", "209.85.204.0/22"]
}
