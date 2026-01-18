locals {
  letsencrypt_servers = {
    staging    = "https://acme-staging-v02.api.letsencrypt.org/directory"
    production = "https://acme-v02.api.letsencrypt.org/directory"
  }
}

# Deploy cert-manager via Helm
resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true
  wait             = true
  timeout          = var.timeout

  values = [
    yamlencode({
      crds = {
        enabled = var.install_crds
      }
      replicaCount = var.controller_replicas
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
      webhook = {
        replicaCount = var.webhook_replicas
        resources = {
          requests = {
            cpu    = var.webhook_resources.requests.cpu
            memory = var.webhook_resources.requests.memory
          }
          limits = {
            cpu    = var.webhook_resources.limits.cpu
            memory = var.webhook_resources.limits.memory
          }
        }
      }
      cainjector = {
        resources = {
          requests = {
            cpu    = var.cainjector_resources.requests.cpu
            memory = var.cainjector_resources.requests.memory
          }
          limits = {
            cpu    = var.cainjector_resources.limits.cpu
            memory = var.cainjector_resources.limits.memory
          }
        }
      }
    })
  ]
}

# Self-signed ClusterIssuer for internal certificates
resource "kubectl_manifest" "selfsigned_issuer" {
  count      = var.create_selfsigned_issuer ? 1 : 0
  depends_on = [helm_release.cert_manager]

  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "selfsigned-issuer"
    }
    spec = {
      selfSigned = {}
    }
  })
}

# Self-signed CA for issuing certificates
resource "kubectl_manifest" "selfsigned_ca_certificate" {
  count      = var.create_selfsigned_issuer ? 1 : 0
  depends_on = [kubectl_manifest.selfsigned_issuer]

  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "selfsigned-ca"
      namespace = var.namespace
    }
    spec = {
      isCA       = true
      commonName = "selfsigned-ca"
      secretName = "selfsigned-ca-secret"
      privateKey = {
        algorithm = "ECDSA"
        size      = 256
      }
      issuerRef = {
        name  = "selfsigned-issuer"
        kind  = "ClusterIssuer"
        group = "cert-manager.io"
      }
    }
  })
}

# CA ClusterIssuer using the self-signed CA
resource "kubectl_manifest" "ca_issuer" {
  count      = var.create_selfsigned_issuer ? 1 : 0
  depends_on = [kubectl_manifest.selfsigned_ca_certificate]

  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "ca-issuer"
    }
    spec = {
      ca = {
        secretName = "selfsigned-ca-secret"
      }
    }
  })
}

# Cloudflare API token secret for DNS01 challenges
resource "kubectl_manifest" "cloudflare_api_token" {
  count      = var.dns01_enabled && var.cloudflare_api_token != "" ? 1 : 0
  depends_on = [helm_release.cert_manager]

  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "Secret"
    metadata = {
      name      = "cloudflare-api-token"
      namespace = var.namespace
    }
    type = "Opaque"
    stringData = {
      api-token = var.cloudflare_api_token
    }
  })
}

# Let's Encrypt ClusterIssuer with HTTP01 challenge
resource "kubectl_manifest" "letsencrypt_issuer" {
  count      = var.create_letsencrypt_issuer && var.letsencrypt_email != "" ? 1 : 0
  depends_on = [helm_release.cert_manager]

  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-${var.letsencrypt_server}"
    }
    spec = {
      acme = {
        email  = var.letsencrypt_email
        server = local.letsencrypt_servers[var.letsencrypt_server]
        privateKeySecretRef = {
          name = "letsencrypt-${var.letsencrypt_server}-account-key"
        }
        solvers = concat(
          # HTTP01 solver (default)
          [
            {
              http01 = {
                ingress = {
                  class = "nginx"
                }
              }
            }
          ],
          # DNS01 solver for Cloudflare (if enabled)
          var.dns01_enabled && var.cloudflare_api_token != "" ? [
            {
              dns01 = {
                cloudflare = {
                  email = var.cloudflare_email
                  apiTokenSecretRef = {
                    name = "cloudflare-api-token"
                    key  = "api-token"
                  }
                }
              }
              selector = {
                dnsZones = [] # Empty = all zones
              }
            }
          ] : []
        )
      }
    }
  })
}
