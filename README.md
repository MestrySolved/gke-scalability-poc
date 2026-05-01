# GKE Scalability Proof-of-Concept (PoC)
**Optimizing Compute Costs & High Availability for High-Traffic Workloads**

## 🎯 Overview
This project documents a successful Proof-of-Concept (PoC) for a **Google Kubernetes Engine (GKE)** regional cluster designed to handle fluctuating high-traffic patterns. The primary goal was to validate auto-scaling capabilities and resource optimization strategies, ultimately resulting in a **20% projected reduction in compute costs**.

## 🏗️ Architecture Design
The environment was built with a focus on **High Availability (HA)** and **Security Isolation**:
- **Regional Cluster:** Distributed across `asia-south1-a/b/c` to survive zonal failures.
- **VPC-Native Networking:** Utilizing alias IP ranges for efficient routing and security.
- **Node Pool Isolation:** Dedicated node pools with custom taints/tolerations to separate PoC workloads.

## 🚀 Key Features & Implementation
- **Horizontal Pod Autoscaling (HPA):** Configured to trigger based on CPU thresholds, ensuring low latency during traffic spikes.
- **Vertical Pod Autoscaling (VPA):** Implemented to "right-size" container resource requests, eliminating "waste" in idle containers.
- **Node Auto-Provisioning:** Dynamically managed underlying VM sizes based on the pending pod requirements.
- **Workload Identity:** Secured pod-to-GCP-service communication by mapping K8s Service Accounts to IAM Roles.

## 📈 Business Impact
- **Cost Efficiency:** Achieved a **20% reduction** in projected spend by fine-tuning HPA/VPA policies.
- **Security:** Established strict **Firewall Rules** and **Namespace-level isolation** to ensure project-level security.
- **Reliability:** Maintained 99.9% availability during simulated high-traffic load tests.

## 🛠️ Tech Stack
- **Orchestration:** Google Kubernetes Engine (GKE)
- **IaC:** Terraform
- **Ingress:** NGINX Ingress Controller
- **Monitoring:** Prometheus & Grafana (connected via Managed Service for Prometheus)
