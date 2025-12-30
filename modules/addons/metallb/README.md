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
  version = ">= 1.2.0"

  ip_range = "192.168.1.200-192.168.1.220"
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.0 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 1.14 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.0 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | >= 1.14 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ip_range"></a> [ip\_range](#input\_ip\_range) | IP range for LoadBalancer services (e.g., 192.168.1.200-192.168.1.220) | `string` | n/a | yes |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | MetalLB Helm chart version | `string` | `"0.14.9"` | no |
| <a name="input_pool_name"></a> [pool\_name](#input\_pool\_name) | Name of the IP address pool | `string` | `"default-pool"` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Helm install timeout in seconds | `number` | `300` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_chart_version"></a> [chart\_version](#output\_chart\_version) | Deployed chart version |
| <a name="output_ip_range"></a> [ip\_range](#output\_ip\_range) | Configured IP range |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | MetalLB namespace |
| <a name="output_pool_name"></a> [pool\_name](#output\_pool\_name) | IP address pool name |
<!-- END_TF_DOCS -->

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
