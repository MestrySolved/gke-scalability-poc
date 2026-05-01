output "cluster_name" {
  description = "The name of the GKE cluster"
  value       = google_container_cluster.primary.name
}

output "cluster_location" {
  description = "The region/location of the GKE cluster"
  value       = google_container_cluster.primary.location
}

output "kubernetes_cluster_endpoint" {
  description = "The IP address of the cluster master"
  value       = google_container_cluster.primary.endpoint
  sensitive   = true
}

output "node_pool_name" {
  description = "The name of the provisioned node pool"
  value       = google_container_node_pool.primary_nodes.name
}

output "service_account_email" {
  description = "The email of the service account used by nodes"
  value       = google_service_account.gke_sa.email
}

output "get_credentials_command" {
  description = "Command to configure kubectl to use this cluster"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region ${google_container_cluster.primary.location}"
}
