output "cluster_endpoint" {
  description = "Kubernetes API endpoint"
  value       = module.cluster.cluster_endpoint
}

output "kubeconfig_path" {
  description = "Path to kubeconfig file"
  value       = module.cluster.kubeconfig_path
}

output "talosconfig_path" {
  description = "Path to talosconfig file"
  value       = "${path.module}/talosconfig"
}

output "metallb_pool" {
  description = "MetalLB IP pool name"
  value       = module.metallb.pool_name
}

output "ingress_namespace" {
  description = "Ingress-NGINX namespace"
  value       = module.ingress.namespace
}

output "grafana_url" {
  description = "Grafana URL"
  value       = "http://grafana.local (add to /etc/hosts: ${var.ingress_ip} grafana.local)"
}

output "portainer_url" {
  description = "Portainer agent URL (connect from Portainer CE/BE)"
  value       = module.portainer.connection_url
}

output "longhorn_ui" {
  description = "Longhorn UI access command"
  value       = "kubectl port-forward -n longhorn-system svc/longhorn-frontend 8080:80"
}
