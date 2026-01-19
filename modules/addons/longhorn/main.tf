locals {
  values = yamlencode({
    defaultSettings = merge(
      {
        defaultReplicaCount = var.default_replica_count
        defaultDataPath     = var.default_data_path
      },
      var.backup_target != null ? {
        backupTarget = var.backup_target
      } : {},
      var.backup_target_credential_secret != null ? {
        backupTargetCredentialSecret = var.backup_target_credential_secret
      } : {}
    )

    persistence = {
      defaultClass             = var.set_default_storage_class
      defaultClassReplicaCount = var.default_replica_count
    }

    longhornManager = {
      resources = {
        requests = {
          memory = var.manager_resources.requests.memory
          cpu    = var.manager_resources.requests.cpu
        }
        limits = {
          memory = var.manager_resources.limits.memory
          cpu    = var.manager_resources.limits.cpu
        }
      }
    }

    longhornUI = {
      replicas = var.ui_replicas
    }
  })
}

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

resource "helm_release" "longhorn" {
  name             = "longhorn"
  repository       = "https://charts.longhorn.io"
  chart            = "longhorn"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = !var.privileged_namespace
  wait             = true
  timeout          = var.timeout

  depends_on = [kubectl_manifest.namespace]

  values = [local.values]
}

# Create NVMe-optimized storage class if enabled
resource "kubectl_manifest" "nvme_storage_class" {
  count      = var.create_nvme_storage_class ? 1 : 0
  depends_on = [helm_release.longhorn]

  yaml_body = yamlencode({
    apiVersion = "storage.k8s.io/v1"
    kind       = "StorageClass"
    metadata = {
      name = "longhorn-nvme"
      annotations = var.set_nvme_as_default ? {
        "storageclass.kubernetes.io/is-default-class" = "true"
      } : {}
    }
    provisioner          = "driver.longhorn.io"
    allowVolumeExpansion = true
    reclaimPolicy        = "Delete"
    volumeBindingMode    = "Immediate"
    parameters = {
      numberOfReplicas    = tostring(var.nvme_replica_count)
      staleReplicaTimeout = "2880"
      fromBackup          = ""
      diskSelector        = "nvme"
      nodeSelector        = ""
    }
  })
}

# Ingress for Longhorn UI (optional)
resource "kubectl_manifest" "longhorn_ingress" {
  count      = var.ingress_enabled ? 1 : 0
  depends_on = [helm_release.longhorn]

  yaml_body = yamlencode({
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"
    metadata = {
      name      = "longhorn-ingress"
      namespace = var.namespace
      annotations = merge(
        {
          "kubernetes.io/ingress.class" = "nginx"
        },
        var.ingress_annotations
      )
    }
    spec = {
      ingressClassName = "nginx"
      rules = [
        {
          host = var.ingress_host
          http = {
            paths = [
              {
                path     = "/"
                pathType = "Prefix"
                backend = {
                  service = {
                    name = "longhorn-frontend"
                    port = {
                      number = 80
                    }
                  }
                }
              }
            ]
          }
        }
      ]
    }
  })
}
