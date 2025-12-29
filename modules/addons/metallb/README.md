# MetalLB Kubernetes Addon Module

Terraform module to deploy [MetalLB](https://metallb.universe.tf/) load balancer on a Kubernetes cluster.

## Usage

```hcl
provider "helm" {
  kubernetes {
    config_path = "./kubeconfig"
  }
}

provider "kubectl" {
  config_path = "./kubeconfig"
}

module "metallb" {
  source  = "jfreed-dev/metallb/kubernetes"
  version = "1.0.0"

  ip_range = "192.168.1.200-192.168.1.220"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| helm | >= 2.0 |
| kubectl | >= 1.14 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ip_range | IP range for LoadBalancer services (e.g., "192.168.1.200-192.168.1.220") | `string` | n/a | yes |
| pool_name | Name of the IP address pool | `string` | `"default-pool"` | no |
| chart_version | MetalLB Helm chart version | `string` | `"0.14.9"` | no |
| timeout | Helm install timeout in seconds | `number` | `300` | no |

## Outputs

| Name | Description |
|------|-------------|
| namespace | MetalLB namespace |
| pool_name | IP address pool name |

## Provider Configuration

This module requires the `helm` and `kubectl` providers to be configured with access to your Kubernetes cluster:

```hcl
provider "helm" {
  kubernetes {
    config_path = "./kubeconfig"
  }
}

provider "kubectl" {
  config_path = "./kubeconfig"
}
```

## License

Apache 2.0 - See [LICENSE](../../../LICENSE) for details.
