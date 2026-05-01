variable "project_id" {
  description = "The GCP Project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for the cluster"
  type        = string
  default     = "asia-south1"
}

variable "zone" {
  description = "The primary GCP zone"
  type        = string
  default     = "asia-south1-a"
}
