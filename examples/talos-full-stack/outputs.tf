output "cluster_endpoint" {
  description = "Kubernetes API endpoint"
  value       = module.cluster.cluster_endpoint
}

output "kubeconfig_path" {
  description = "Path to kubeconfig file"
  value       = module.cluster.kubeconfig_path
}

output "metallb_pool" {
  description = "MetalLB IP pool name"
  value       = module.metallb.pool_name
}

output "ingress_namespace" {
  description = "Ingress-NGINX namespace"
  value       = module.ingress.namespace
}
