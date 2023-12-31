resource "google_dns_managed_zone" "derp_public" {
  name        = "derp-louhintamestarit-fi"
  dns_name    = "derp.louhintamestarit.fi."
  description = "derp.louhintamestarit.fi subdomain zone"
}

resource "google_dns_record_set" "derp" {
  name         = google_dns_managed_zone.derp_public.dns_name
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.derp_public.name

  rrdatas = [google_compute_address.derp1_public.address]
}

resource "google_dns_record_set" "derp_ipv6" {
  name         = google_dns_managed_zone.derp_public.dns_name
  type         = "AAAA"
  ttl          = 300
  managed_zone = google_dns_managed_zone.derp_public.name

  rrdatas = [google_compute_address.derp1_ipv6.address]
}
