output "namespace" {
  description = "Ingress-NGINX namespace"
  value       = helm_release.ingress_nginx.namespace
}

output "controller_service" {
  description = "Ingress controller service name"
  value       = "ingress-nginx-controller"
}

output "chart_version" {
  description = "Deployed chart version"
  value       = helm_release.ingress_nginx.version
}

output "loadbalancer_ip" {
  description = "LoadBalancer IP (if specified)"
  value       = var.loadbalancer_ip
}
