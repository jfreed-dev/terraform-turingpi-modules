# Turing Pi Talos Cluster Module

Terraform module to deploy a Talos Kubernetes cluster on Turing Pi 2.5 nodes using the native [Talos Terraform Provider](https://registry.terraform.io/providers/siderolabs/talos/latest).

## Usage

```hcl
module "cluster" {
  source  = "jfreed-dev/talos-cluster/turingpi"
  version = "1.0.0"

  cluster_name     = "my-cluster"
  cluster_endpoint = "https://192.168.1.101:6443"

  control_plane = [
    { host = "192.168.1.101", hostname = "cp1" }
  ]

  workers = [
    { host = "192.168.1.102", hostname = "worker1" },
    { host = "192.168.1.103", hostname = "worker2" },
    { host = "192.168.1.104", hostname = "worker3" }
  ]

  kubeconfig_path = "./kubeconfig"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| talos | >= 0.7 |
| local | >= 2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | Name of the Kubernetes cluster | `string` | n/a | yes |
| cluster_endpoint | Kubernetes API endpoint (https://IP:6443) | `string` | n/a | yes |
| control_plane | Control plane node configurations | `list(object({ host = string, hostname = optional(string) }))` | n/a | yes |
| workers | Worker node configurations | `list(object({ host = string, hostname = optional(string) }))` | `[]` | no |
| controlplane_patches | Config patches for control plane nodes (YAML strings) | `list(string)` | `[]` | no |
| worker_patches | Config patches for worker nodes (YAML strings) | `list(string)` | `[]` | no |
| kubeconfig_path | Path to write kubeconfig file | `string` | `null` | no |
| allow_scheduling_on_control_plane | Allow workloads on control plane nodes | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| kubeconfig | Kubeconfig for cluster access (sensitive) |
| client_configuration | Talos client configuration for talosctl (sensitive) |
| machine_secrets | Talos machine secrets for backup (sensitive) |
| cluster_endpoint | Kubernetes API endpoint |
| kubeconfig_path | Path to kubeconfig file (if written) |

## Prerequisites

Nodes must be pre-flashed with Talos Linux. Use the [flash-nodes](../flash-nodes) module or the `turingpi_flash` resource.

## License

Apache 2.0 - See [LICENSE](../../LICENSE) for details.
