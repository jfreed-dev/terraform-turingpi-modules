output "namespace" {
  description = "Monitoring namespace"
  value       = helm_release.kube_prometheus_stack.namespace
}

output "chart_version" {
  description = "Deployed chart version"
  value       = helm_release.kube_prometheus_stack.version
}

output "grafana_url" {
  description = "Grafana URL (if ingress enabled)"
  value       = var.grafana_ingress_enabled ? "http://${var.grafana_ingress_host}" : null
}

output "prometheus_url" {
  description = "Prometheus URL (if ingress enabled)"
  value       = var.prometheus_ingress_enabled ? "http://${var.prometheus_ingress_host}" : null
}

output "alertmanager_url" {
  description = "Alertmanager URL (if ingress enabled)"
  value       = var.alertmanager_ingress_enabled ? "http://${var.alertmanager_ingress_host}" : null
}

output "grafana_service" {
  description = "Grafana service name for port-forwarding"
  value       = var.grafana_enabled ? "kube-prometheus-stack-grafana" : null
}

output "prometheus_service" {
  description = "Prometheus service name for port-forwarding"
  value       = var.prometheus_enabled ? "kube-prometheus-stack-prometheus" : null
}
