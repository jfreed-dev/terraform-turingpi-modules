output "kubeconfig" {
  description = "Kubeconfig for cluster access"
  value       = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive   = true
}

output "client_configuration" {
  description = "Talos client configuration for talosctl"
  value       = talos_machine_secrets.this.client_configuration
  sensitive   = true
}

output "machine_secrets" {
  description = "Talos machine secrets (for backup)"
  value       = talos_machine_secrets.this.machine_secrets
  sensitive   = true
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint"
  value       = var.cluster_endpoint
}

output "cluster_name" {
  description = "Cluster name"
  value       = var.cluster_name
}

output "kubeconfig_path" {
  description = "Path to kubeconfig file (if written)"
  value       = var.kubeconfig_path != null ? var.kubeconfig_path : null
}
