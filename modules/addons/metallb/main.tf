# Create namespace with PodSecurity labels (required for Talos and PSA-enabled clusters)
resource "kubectl_manifest" "namespace" {
  count = var.privileged_namespace ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "Namespace"
    metadata = {
      name = var.namespace
      labels = {
        "pod-security.kubernetes.io/enforce" = "privileged"
        "pod-security.kubernetes.io/audit"   = "privileged"
        "pod-security.kubernetes.io/warn"    = "privileged"
      }
    }
  })
}

# Deploy MetalLB via Helm
resource "helm_release" "metallb" {
  name             = "metallb"
  repository       = "https://metallb.github.io/metallb"
  chart            = "metallb"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = !var.privileged_namespace
  wait             = true
  timeout          = var.timeout

  depends_on = [kubectl_manifest.namespace]

  values = [
    yamlencode({
      controller = {
        resources = {
          requests = var.controller_resources.requests != null ? {
            cpu    = var.controller_resources.requests.cpu
            memory = var.controller_resources.requests.memory
          } : null
          limits = var.controller_resources.limits != null ? {
            cpu    = var.controller_resources.limits.cpu
            memory = var.controller_resources.limits.memory
          } : null
        }
      }
      speaker = {
        resources = {
          requests = var.speaker_resources.requests != null ? {
            cpu    = var.speaker_resources.requests.cpu
            memory = var.speaker_resources.requests.memory
          } : null
          limits = var.speaker_resources.limits != null ? {
            cpu    = var.speaker_resources.limits.cpu
            memory = var.speaker_resources.limits.memory
          } : null
        }
      }
    })
  ]
}

# Create IPAddressPool
resource "kubectl_manifest" "ip_pool" {
  depends_on = [helm_release.metallb]

  yaml_body = yamlencode({
    apiVersion = "metallb.io/v1beta1"
    kind       = "IPAddressPool"
    metadata = {
      name      = var.pool_name
      namespace = var.namespace
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
      namespace = var.namespace
    }
    spec = {
      ipAddressPools = [var.pool_name]
    }
  })
}
