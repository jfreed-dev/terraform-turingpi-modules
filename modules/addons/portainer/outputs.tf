output "namespace" {
  description = "Portainer namespace"
  value       = "portainer"
}

output "service_name" {
  description = "Portainer agent service name"
  value       = "portainer-agent"
}

output "service_type" {
  description = "Service type"
  value       = var.service_type
}

output "agent_port" {
  description = "Agent port"
  value       = 9001
}

output "node_port" {
  description = "NodePort (if service type is NodePort)"
  value       = var.service_type == "NodePort" ? var.node_port : null
}

output "loadbalancer_ip" {
  description = "LoadBalancer IP (if specified)"
  value       = var.loadbalancer_ip
}

output "connection_url" {
  description = "URL to connect from Portainer CE/BE"
  value       = var.loadbalancer_ip != null ? "${var.loadbalancer_ip}:9001" : null
}

output "agent_version" {
  description = "Deployed agent version"
  value       = var.agent_version
}
