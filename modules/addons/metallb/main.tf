# Deploy MetalLB via Helm
resource "helm_release" "metallb" {
  name             = "metallb"
  repository       = "https://metallb.github.io/metallb"
  chart            = "metallb"
  version          = var.chart_version
  namespace        = "metallb-system"
  create_namespace = true
  wait             = true
  timeout          = var.timeout
}

# Create IPAddressPool
resource "kubectl_manifest" "ip_pool" {
  depends_on = [helm_release.metallb]

  yaml_body = yamlencode({
    apiVersion = "metallb.io/v1beta1"
    kind       = "IPAddressPool"
    metadata = {
      name      = var.pool_name
      namespace = "metallb-system"
    }
    spec = {
      addresses = [var.ip_range]
    }
  })
}

# Create L2Advertisement
resource "kubectl_manifest" "l2_advertisement" {
  depends_on = [kubectl_manifest.ip_pool]

  yaml_body = yamlencode({
    apiVersion = "metallb.io/v1beta1"
    kind       = "L2Advertisement"
    metadata = {
      name      = "default"
      namespace = "metallb-system"
    }
    spec = {
      ipAddressPools = [var.pool_name]
    }
  })
}
