# --- Provider & Project Details ---
provider "google" {
  project = "your-project-id" # Update with your project ID
  region  = "asia-south1"
}

# --- VPC Network (VPC-Native) ---
resource "google_compute_network" "gke_vpc" {
  name                    = "gke-poc-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "gke_subnet" {
  name          = "gke-poc-subnet"
  ip_cidr_range = "10.0.0.0/20"
  region        = "asia-south1"
  network       = google_compute_network.gke_vpc.id

  # Alias ranges for VPC-Native GKE
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
  location = "asia-south1" # Making it Regional (HA)

  # Enabling VPC-Native Networking
  networking_mode = "VPC_NATIVE"
  network         = google_compute_network.gke_vpc.name
  subnetwork      = google_compute_subnetwork.gke_subnet.name

  ip_allocation_policy {
    cluster_secondary_range_name  = "pod-ranges"
    services_secondary_range_name = "service-ranges"
  }

  # We create a separate node pool, so we delete the default one
  remove_default_node_pool = true
  initial_node_count       = 1

  # Security: Enable Workload Identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Cost Optimization: Enable Vertical Pod Autoscaling
  vertical_pod_autoscaling {
    enabled = true
  }
}

# --- Managed Node Pool with Autoscaling ---
resource "google_container_node_pool" "primary_nodes" {
  name       = "autoscaling-node-pool"
  location   = "asia-south1"
  cluster    = google_container_cluster.primary.name
  node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 5 # Scalability for high-traffic apps
  }

  node_config {
    machine_type = "e2-medium"
    
    # IAM & Security
    service_account = google_service_account.gke_sa.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

# --- IAM for Workload Identity ---
resource "google_service_account" "gke_sa" {
  account_id   = "gke-poc-sa"
  display_name = "GKE PoC Service Account"
}
