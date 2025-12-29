locals {
  additional_scrape_configs = concat(
    # External node exporters
    length(var.external_targets) > 0 ? [
      {
        job_name = "external-nodes"
        static_configs = [
          {
            targets = [for t in var.external_targets : "${t}:9100"]
          }
        ]
      }
    ] : [],
    # External Docker daemon metrics
    length(var.docker_hosts) > 0 ? [
      {
        job_name = "docker-hosts"
        static_configs = [
          {
            targets = [for t in var.docker_hosts : "${t}:9323"]
          }
        ]
        metrics_path = "/metrics"
      }
    ] : [],
    # External cAdvisor
    length(var.cadvisor_hosts) > 0 ? [
      {
        job_name = "external-cadvisor"
        static_configs = [
          {
            targets = [for t in var.cadvisor_hosts : "${t}:8080"]
          }
        ]
        metrics_path = "/metrics"
      }
    ] : []
  )

  grafana_ingress = var.grafana_ingress_enabled ? {
    enabled          = true
    ingressClassName = "nginx"
    hosts            = [var.grafana_ingress_host]
  } : {
    enabled          = false
    ingressClassName = ""
    hosts            = []
  }

  prometheus_ingress = var.prometheus_ingress_enabled ? {
    enabled          = true
    ingressClassName = "nginx"
    hosts            = [var.prometheus_ingress_host]
  } : {
    enabled          = false
    ingressClassName = ""
    hosts            = []
  }

  alertmanager_ingress = var.alertmanager_ingress_enabled ? {
    enabled          = true
    ingressClassName = "nginx"
    hosts            = [var.alertmanager_ingress_host]
  } : {
    enabled          = false
    ingressClassName = ""
    hosts            = []
  }

  values = yamlencode({
    # Grafana Configuration
    grafana = {
      enabled       = var.grafana_enabled
      adminPassword = var.grafana_admin_password

      persistence = {
        enabled          = var.grafana_persistence_enabled
        storageClassName = var.storage_class
        size             = var.grafana_storage_size
      }

      ingress = local.grafana_ingress

      sidecar = {
        dashboards = {
          enabled         = true
          searchNamespace = "ALL"
        }
      }
    }

    # Prometheus Configuration
    prometheus = {
      enabled = var.prometheus_enabled

      ingress = local.prometheus_ingress

      prometheusSpec = merge(
        {
          retention     = var.prometheus_retention
          retentionSize = var.prometheus_retention_size

          storageSpec = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = var.storage_class
                accessModes      = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = var.prometheus_storage_size
                  }
                }
              }
            }
          }

          resources = {
            requests = {
              memory = var.prometheus_memory_request
              cpu    = var.prometheus_cpu_request
            }
            limits = {
              memory = var.prometheus_memory_limit
              cpu    = var.prometheus_cpu_limit
            }
          }

          podMonitorSelectorNilUsesHelmValues     = false
          serviceMonitorSelectorNilUsesHelmValues = false
        },
        length(local.additional_scrape_configs) > 0 ? {
          additionalScrapeConfigs = local.additional_scrape_configs
        } : {}
      )
    }

    # Alertmanager Configuration
    alertmanager = {
      enabled = var.alertmanager_enabled

      ingress = local.alertmanager_ingress

      alertmanagerSpec = {
        storage = {
          volumeClaimTemplate = {
            spec = {
              storageClassName = var.storage_class
              accessModes      = ["ReadWriteOnce"]
              resources = {
                requests = {
                  storage = var.alertmanager_storage_size
                }
              }
            }
          }
        }
      }
    }

    # Node Exporter
    nodeExporter = {
      enabled = var.node_exporter_enabled
    }

    # Kube State Metrics
    kubeStateMetrics = {
      enabled = var.kube_state_metrics_enabled
    }

    # Kubernetes component scraping
    kubeApiServer = {
      enabled = true
    }

    kubeControllerManager = merge(
      {
        enabled = true
      },
      var.control_plane_endpoint != null ? {
        endpoints = [var.control_plane_endpoint]
      } : {}
    )

    kubeScheduler = merge(
      {
        enabled = true
      },
      var.control_plane_endpoint != null ? {
        endpoints = [var.control_plane_endpoint]
      } : {}
    )

    kubeProxy = {
      enabled = true
    }

    kubeEtcd = merge(
      {
        enabled = true
      },
      var.control_plane_endpoint != null ? {
        endpoints = [var.control_plane_endpoint]
      } : {}
    )

    kubelet = {
      enabled = true
    }
  })
}

resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = var.chart_version
  namespace        = "monitoring"
  create_namespace = true
  wait             = true
  timeout          = var.timeout

  values = [local.values]
}
