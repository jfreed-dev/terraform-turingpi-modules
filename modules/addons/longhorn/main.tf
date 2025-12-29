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
          memory = "128Mi"
          cpu    = "100m"
        }
      }
    }

    longhornUI = {
      replicas = 1
    }
  })
}

resource "helm_release" "longhorn" {
  name             = "longhorn"
  repository       = "https://charts.longhorn.io"
  chart            = "longhorn"
  version          = var.chart_version
  namespace        = "longhorn-system"
  create_namespace = true
  wait             = true
  timeout          = var.timeout

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
      namespace = "longhorn-system"
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
