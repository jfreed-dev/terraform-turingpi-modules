# Namespace
resource "kubectl_manifest" "namespace" {
  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "Namespace"
    metadata = {
      name = "portainer"
    }
  })
}

# Service Account
resource "kubectl_manifest" "service_account" {
  depends_on = [kubectl_manifest.namespace]

  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "ServiceAccount"
    metadata = {
      name      = "portainer-sa-clusteradmin"
      namespace = "portainer"
    }
  })
}

# Cluster Role Binding
resource "kubectl_manifest" "cluster_role_binding" {
  depends_on = [kubectl_manifest.service_account]

  yaml_body = yamlencode({
    apiVersion = "rbac.authorization.k8s.io/v1"
    kind       = "ClusterRoleBinding"
    metadata = {
      name = "portainer-crb-clusteradmin"
    }
    roleRef = {
      apiGroup = "rbac.authorization.k8s.io"
      kind     = "ClusterRole"
      name     = "cluster-admin"
    }
    subjects = [
      {
        kind      = "ServiceAccount"
        name      = "portainer-sa-clusteradmin"
        namespace = "portainer"
      }
    ]
  })
}

# Service (NodePort or LoadBalancer)
resource "kubectl_manifest" "service" {
  depends_on = [kubectl_manifest.namespace]

  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = "portainer-agent"
      namespace = "portainer"
      annotations = var.loadbalancer_ip != null ? {
        "metallb.universe.tf/loadBalancerIPs" = var.loadbalancer_ip
      } : {}
    }
    spec = {
      type = var.service_type
      selector = {
        app = "portainer-agent"
      }
      ports = [
        {
          name       = "http"
          protocol   = "TCP"
          port       = 9001
          targetPort = 9001
          nodePort   = var.service_type == "NodePort" ? var.node_port : null
        }
      ]
    }
  })
}

# Headless Service for agent discovery
resource "kubectl_manifest" "service_headless" {
  depends_on = [kubectl_manifest.namespace]

  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = "portainer-agent-headless"
      namespace = "portainer"
    }
    spec = {
      clusterIP = "None"
      selector = {
        app = "portainer-agent"
      }
    }
  })
}

# Deployment
resource "kubectl_manifest" "deployment" {
  depends_on = [
    kubectl_manifest.service_account,
    kubectl_manifest.service,
    kubectl_manifest.service_headless
  ]

  yaml_body = yamlencode({
    apiVersion = "apps/v1"
    kind       = "Deployment"
    metadata = {
      name      = "portainer-agent"
      namespace = "portainer"
    }
    spec = {
      replicas = 1
      selector = {
        matchLabels = {
          app = "portainer-agent"
        }
      }
      template = {
        metadata = {
          labels = {
            app = "portainer-agent"
          }
        }
        spec = {
          serviceAccountName = "portainer-sa-clusteradmin"
          containers = [
            {
              name            = "portainer-agent"
              image           = "portainer/agent:${var.agent_version}"
              imagePullPolicy = "Always"
              env = [
                {
                  name  = "LOG_LEVEL"
                  value = var.log_level
                },
                {
                  name  = "AGENT_CLUSTER_ADDR"
                  value = "portainer-agent-headless"
                },
                {
                  name = "KUBERNETES_POD_IP"
                  valueFrom = {
                    fieldRef = {
                      fieldPath = "status.podIP"
                    }
                  }
                }
              ]
              ports = [
                {
                  containerPort = 9001
                  protocol      = "TCP"
                }
              ]
              resources = {
                requests = {
                  memory = var.memory_request
                  cpu    = var.cpu_request
                }
                limits = {
                  memory = var.memory_limit
                  cpu    = var.cpu_limit
                }
              }
            }
          ]
        }
      }
    }
  })
}
