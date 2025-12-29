output "kubeconfig" {
  description = "Kubeconfig for cluster access"
  value       = data.local_file.kubeconfig.content
  sensitive   = true
}

output "api_endpoint" {
  description = "Kubernetes API endpoint"
  value       = local.api_endpoint
}

output "cluster_name" {
  description = "Cluster name"
  value       = var.cluster_name
}

output "cluster_token" {
  description = "Cluster token for joining nodes"
  value       = local.cluster_token
  sensitive   = true
}

output "control_plane_host" {
  description = "Control plane host IP/hostname"
  value       = var.control_plane.host
}

output "worker_hosts" {
  description = "Worker node host IPs/hostnames"
  value       = [for w in var.workers : w.host]
}

output "kubeconfig_path" {
  description = "Path to kubeconfig file (if written)"
  value       = var.kubeconfig_path
}

output "nvme_enabled" {
  description = "Whether NVMe storage is configured"
  value       = var.nvme_storage_enabled
}

output "nvme_mountpoint" {
  description = "NVMe mount point (if enabled)"
  value       = var.nvme_storage_enabled ? var.nvme_mountpoint : null
}

output "k3s_version" {
  description = "Installed K3s version"
  value       = var.k3s_version != "" ? var.k3s_version : "latest"
}
