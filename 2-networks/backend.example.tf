terraform {
  backend "gcs" {
    bucket = "STATE_BUCKET"
    prefix = "terraform/networks/state"
  }
}
