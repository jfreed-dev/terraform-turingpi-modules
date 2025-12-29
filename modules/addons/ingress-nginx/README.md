# Ingress-NGINX Kubernetes Addon Module

Terraform module to deploy [Ingress-NGINX](https://kubernetes.github.io/ingress-nginx/) controller on a Kubernetes cluster.

## Usage

```hcl
provider "helm" {
  kubernetes {
    config_path = "./kubeconfig"
  }
}

module "ingress" {
  source  = "jfreed-dev/ingress-nginx/kubernetes"
  version = "1.0.0"

  loadbalancer_ip = "192.168.1.200"  # Optional: use with MetalLB
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
| loadbalancer_ip | Static IP for ingress LoadBalancer (optional, use with MetalLB) | `string` | `null` | no |
| chart_version | Ingress-NGINX Helm chart version | `string` | `"4.11.3"` | no |
| timeout | Helm install timeout in seconds | `number` | `300` | no |
| enable_admission_webhooks | Enable admission webhooks | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| namespace | Ingress-NGINX namespace |
| controller_service | Ingress controller service name |

## Provider Configuration

This module requires the `helm` provider to be configured with access to your Kubernetes cluster:

```hcl
provider "helm" {
  kubernetes {
    config_path = "./kubeconfig"
  }
}
```

## Using with MetalLB

When using with the MetalLB module, specify a `loadbalancer_ip` from your MetalLB IP pool:

```hcl
module "metallb" {
  source   = "jfreed-dev/metallb/kubernetes"
  ip_range = "192.168.1.200-192.168.1.220"
}

module "ingress" {
  source          = "jfreed-dev/ingress-nginx/kubernetes"
  depends_on      = [module.metallb]
  loadbalancer_ip = "192.168.1.200"
}
```

## License

Apache 2.0 - See [LICENSE](../../../LICENSE) for details.
