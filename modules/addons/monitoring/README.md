# Kubernetes Monitoring Module (kube-prometheus-stack)

Terraform module to deploy the [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) for comprehensive Kubernetes monitoring.

Includes:
- **Prometheus** - Metrics collection and storage
- **Grafana** - Visualization and dashboards
- **Alertmanager** - Alert routing and management
- **Node Exporter** - Host-level metrics
- **kube-state-metrics** - Kubernetes state metrics

## Usage

```hcl
module "monitoring" {
  source  = "jfreed-dev/modules/turingpi//modules/addons/monitoring"
  version = ">= 1.0.0"

  # Change default password!
  grafana_admin_password = "your-secure-password"

  # Storage class (requires Longhorn or similar)
  storage_class = "longhorn"

  # Optional: Enable Ingress for web access
  # grafana_ingress_enabled     = true
  # grafana_ingress_host        = "grafana.local"
  # prometheus_ingress_enabled  = true
  # prometheus_ingress_host     = "prometheus.local"
  # alertmanager_ingress_enabled = true
  # alertmanager_ingress_host    = "alertmanager.local"

  # Optional: Talos control plane endpoint for component scraping
  # control_plane_endpoint = "10.10.88.73"

  # Optional: External monitoring targets
  # external_targets = ["192.168.1.100", "192.168.1.101"]
  # docker_hosts     = ["192.168.1.100"]
  # cadvisor_hosts   = ["192.168.1.100"]
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| helm | >= 2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| chart_version | Helm chart version | `string` | `"65.8.1"` | no |
| timeout | Helm install timeout | `number` | `600` | no |
| storage_class | Storage class for PVs | `string` | `"longhorn"` | no |

### Grafana

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| grafana_enabled | Enable Grafana | `bool` | `true` | no |
| grafana_admin_password | Admin password | `string` | `"admin"` | no |
| grafana_persistence_enabled | Enable storage | `bool` | `true` | no |
| grafana_storage_size | PV size | `string` | `"5Gi"` | no |
| grafana_ingress_enabled | Enable Ingress | `bool` | `false` | no |
| grafana_ingress_host | Ingress hostname | `string` | `"grafana.local"` | no |

### Prometheus

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| prometheus_enabled | Enable Prometheus | `bool` | `true` | no |
| prometheus_retention | Data retention | `string` | `"15d"` | no |
| prometheus_retention_size | Max storage size | `string` | `"18GB"` | no |
| prometheus_storage_size | PV size | `string` | `"20Gi"` | no |
| prometheus_memory_request | Memory request | `string` | `"512Mi"` | no |
| prometheus_memory_limit | Memory limit | `string` | `"2Gi"` | no |
| prometheus_cpu_request | CPU request | `string` | `"250m"` | no |
| prometheus_cpu_limit | CPU limit | `string` | `"1000m"` | no |
| prometheus_ingress_enabled | Enable Ingress | `bool` | `false` | no |
| prometheus_ingress_host | Ingress hostname | `string` | `"prometheus.local"` | no |

### Alertmanager

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| alertmanager_enabled | Enable Alertmanager | `bool` | `true` | no |
| alertmanager_storage_size | PV size | `string` | `"2Gi"` | no |
| alertmanager_ingress_enabled | Enable Ingress | `bool` | `false` | no |
| alertmanager_ingress_host | Ingress hostname | `string` | `"alertmanager.local"` | no |

### External Monitoring

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| control_plane_endpoint | CP IP for component scraping | `string` | `null` | no |
| external_targets | External node_exporter hosts | `list(string)` | `[]` | no |
| docker_hosts | Docker daemon metrics hosts | `list(string)` | `[]` | no |
| cadvisor_hosts | cAdvisor hosts | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| namespace | Monitoring namespace |
| chart_version | Deployed chart version |
| grafana_url | Grafana URL (if ingress enabled) |
| prometheus_url | Prometheus URL (if ingress enabled) |
| alertmanager_url | Alertmanager URL (if ingress enabled) |
| grafana_service | Grafana service name |
| prometheus_service | Prometheus service name |

## Accessing Without Ingress

Use kubectl port-forward:

```bash
# Grafana (default: admin/admin)
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80

# Prometheus
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090

# Alertmanager
kubectl port-forward -n monitoring svc/kube-prometheus-stack-alertmanager 9093:9093
```

## License

Apache 2.0 - See [LICENSE](../../../LICENSE) for details.
