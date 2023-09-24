terraform {
  backend "gcs" {
    bucket = "mestari-tf"
    prefix = "terraform/mestari-tf-state"
  }
}
