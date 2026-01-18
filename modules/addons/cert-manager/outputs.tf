output "namespace" {
  description = "Namespace where cert-manager is deployed"
  value       = var.namespace
}

output "selfsigned_issuer_name" {
  description = "Name of the self-signed ClusterIssuer"
  value       = var.create_selfsigned_issuer ? "selfsigned-issuer" : null
}

output "ca_issuer_name" {
  description = "Name of the CA ClusterIssuer"
  value       = var.create_selfsigned_issuer ? "ca-issuer" : null
}

output "letsencrypt_issuer_name" {
  description = "Name of the Let's Encrypt ClusterIssuer"
  value       = var.create_letsencrypt_issuer && var.letsencrypt_email != "" ? "letsencrypt-${var.letsencrypt_server}" : null
}

output "chart_version" {
  description = "Installed cert-manager chart version"
  value       = var.chart_version
}
