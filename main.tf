provider "google-beta" {
  credentials = "${file("account.json")}"
  project = "gcp-rain"
  region  = "us-central1"
  zone    = "us-central1-a"
  version = "2.17"
}

provider "google" {
  credentials = "${file("account.json")}"
  project = "gcp-rain"
  region  = "us-central1"
  zone    = "us-central1-a"
  version = "2.17"
}
resource "google_container_cluster" "primary" {
  name     = "terraform-gke-cluster"
  location = "us-central1"
  remove_default_node_pool = true
  initial_node_count = 1
}
resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "my-node-pool"
  location   = "us-central1"
  cluster    = "${google_container_cluster.primary.name}"
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "f1-micro"

    metadata = {
      disable-legacy-endpoints = "true"
    }
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}
resource "google_cloudbuild_trigger" "filename-trigger" {
  provider = "google-beta"
  github {
    owner = "jeeeevs"
    name = "express"
    push {
      branch = "master"
    }
  }
  filename = "cloudbuild.yaml"
}