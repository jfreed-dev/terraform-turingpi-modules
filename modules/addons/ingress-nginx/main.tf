# Deploy NGINX Ingress Controller via Helm
resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true
  wait             = true
  timeout          = var.timeout

  values = [
    yamlencode({
      controller = {
        replicaCount = var.controller_replicas
        service = merge(
          { type = "LoadBalancer" },
          var.loadbalancer_ip != null ? { loadBalancerIP = var.loadbalancer_ip } : {}
        )
        ingressClassResource = {
          default = var.default_ingress_class
        }
        admissionWebhooks = {
          enabled = var.enable_admission_webhooks
        }
        resources = {
          requests = {
            cpu    = var.controller_resources.requests.cpu
            memory = var.controller_resources.requests.memory
          }
          limits = {
            cpu    = var.controller_resources.limits.cpu
            memory = var.controller_resources.limits.memory
          }
        }
        metrics = {
          enabled = var.enable_metrics
          port    = var.metrics_port
          serviceMonitor = {
            enabled = var.enable_metrics
          }
        }
      }
    })
  ]
}
