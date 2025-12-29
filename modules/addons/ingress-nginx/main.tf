# Deploy NGINX Ingress Controller via Helm
resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = var.chart_version
  namespace        = "ingress-nginx"
  create_namespace = true
  wait             = true
  timeout          = var.timeout

  values = [
    yamlencode({
      controller = {
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
      }
    })
  ]
}
