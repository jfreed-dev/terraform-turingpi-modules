output "namespace" {
  description = "MetalLB namespace"
  value       = helm_release.metallb.namespace
}

output "pool_name" {
  description = "IP address pool name"
  value       = var.pool_name
}

output "ip_range" {
  description = "Configured IP range"
  value       = var.ip_range
}

output "chart_version" {
  description = "Deployed chart version"
  value       = helm_release.metallb.version
}
