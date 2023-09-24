resource "google_compute_network" "mestari" {
  name                    = "mestarivpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "mestari" {
  name             = "mestari"
  ip_cidr_range    = "10.56.0.0/16"
  region           = var.region
  network          = google_compute_network.mestari.id
  stack_type       = "IPV4_IPV6"
  ipv6_access_type = "EXTERNAL"
}

resource "google_compute_address" "derp_lb" {
  name         = "derp-lb"
  region       = var.region
  address_type = "EXTERNAL"
}

resource "google_compute_address" "derp_lb_ipv6" {
  name               = "derp-lb-ipv6"
  region             = var.region
  subnetwork         = google_compute_subnetwork.mestari.id
  ip_version         = "IPV6"
  ipv6_endpoint_type = "NETLB"
}

resource "google_compute_address" "derp1_ipv6" {
  name               = "derp1-ipv6"
  region             = var.region
  subnetwork         = google_compute_subnetwork.mestari.id
  ip_version         = "IPV6"
  ipv6_endpoint_type = "VM"
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

resource "google_compute_firewall" "icmp_ipv6" {
  project = var.project_id
  name    = "allow-icmp-ipv6"
  network = google_compute_network.mestari.id

  allow {
    protocol = "58"
  }
  source_ranges = ["::/0"]
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

resource "google_compute_firewall" "http_https" {
  project = var.project_id
  name    = "allow-http-https"
  network = google_compute_network.mestari.id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "http_https_ipv6" {
  project = var.project_id
  name    = "allow-http-https-ipv6"
  network = google_compute_network.mestari.id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  source_ranges = ["::/0"]
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

resource "google_compute_firewall" "stun_ipv6" {
  project = var.project_id
  name    = "allow-stun-ipv6"
  network = google_compute_network.mestari.id

  allow {
    protocol = "udp"
    ports    = ["3478"]
  }
  source_ranges = ["::/0"]
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

resource "google_compute_firewall" "lb_health_check_ipv6" {
  project = var.project_id
  name    = "lb-health-check-ipv6"
  network = google_compute_network.mestari.id

  allow {
    protocol = "tcp"
  }
  source_ranges = ["2600:1901:8001::/48"]
}
