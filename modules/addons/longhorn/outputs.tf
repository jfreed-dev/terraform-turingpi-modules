output "namespace" {
  description = "Longhorn namespace"
  value       = helm_release.longhorn.namespace
}

output "chart_version" {
  description = "Deployed Longhorn chart version"
  value       = helm_release.longhorn.version
}

output "default_storage_class" {
  description = "Default storage class name"
  value       = "longhorn"
}

output "nvme_storage_class" {
  description = "NVMe storage class name (if created)"
  value       = var.create_nvme_storage_class ? "longhorn-nvme" : null
}

output "ui_url" {
  description = "Longhorn UI URL (if ingress enabled)"
  value       = var.ingress_enabled ? "http://${var.ingress_host}" : null
}
