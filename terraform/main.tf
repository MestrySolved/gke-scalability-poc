# --- Provider & Project Details ---
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# --- VPC Network (VPC-Native) ---
resource "google_compute_network" "gke_vpc" {
  name                    = "gke-poc-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "gke_subnet" {
  name          = "gke-poc-subnet"
  ip_cidr_range = "10.0.0.0/20"
  region        = var.region
  network       = google_compute_network.gke_vpc.id

  secondary_ip_range {
    range_name    = "pod-ranges"
    ip_cidr_range = "10.1.0.0/16"
  }
  secondary_ip_range {
    range_name    = "service-ranges"
    ip_cidr_range = "10.2.0.0/20"
  }
}

# --- GKE Regional Cluster ---
resource "google_container_cluster" "primary" {
  name     = "gke-scalability-poc"
  location = var.region

  networking_mode = "VPC_NATIVE"
  network         = google_compute_network.gke_vpc.name
  subnetwork      = google_compute_subnetwork.gke_subnet.name

  ip_allocation_policy {
    cluster_secondary_range_name  = "pod-ranges"
    services_secondary_range_name = "service-ranges"
  }

  remove_default_node_pool = true
  initial_node_count       = 1

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  vertical_pod_autoscaling {
    enabled = true
  }
}

# --- Managed Node Pool ---
resource "google_container_node_pool" "primary_nodes" {
  name       = "autoscaling-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 5
  }

  node_config {
    machine_type = "e2-medium"
    service_account = google_service_account.gke_sa.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

resource "google_service_account" "gke_sa" {
  account_id   = "gke-poc-sa"
  display_name = "GKE PoC Service Account"
}
