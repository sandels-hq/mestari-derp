# forwarding rule
resource "google_compute_forwarding_rule" "l3" {
  provider        = google-beta
  name            = "derp-l3"
  backend_service = google_compute_region_backend_service.l3.id
  ip_protocol     = "L3_DEFAULT"
  all_ports       = true
  ip_address      = google_compute_address.derp_lb.id
}

resource "google_compute_forwarding_rule" "l3_ipv6" {
  provider        = google-beta
  name            = "derp-l3-ipv6"
  backend_service = google_compute_region_backend_service.l3.id
  ip_protocol     = "L3_DEFAULT"
  all_ports       = true
  ip_address      = google_compute_address.derp_lb_ipv6.id
  ip_version      = "IPV6"
  subnetwork      = google_compute_subnetwork.mestari.id
}


# backend service
resource "google_compute_region_backend_service" "l3" {
  provider              = google-beta
  name                  = "l3"
  health_checks         = [google_compute_region_health_check.l3.id]
  load_balancing_scheme = "EXTERNAL"
  protocol              = "UNSPECIFIED"

  backend {
    group          = google_compute_instance_group.derp.id
    balancing_mode = "CONNECTION"
  }

}

resource "google_compute_region_health_check" "l3" {
  provider = google-beta
  name     = "tcp-proxy-health-check"

  tcp_health_check {
    port = "22"
  }
}
