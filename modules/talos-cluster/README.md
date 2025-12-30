# Turing Pi Talos Cluster Module

Terraform module to deploy a Talos Kubernetes cluster on Turing Pi 2.5 nodes using the native [Talos Terraform Provider](https://registry.terraform.io/providers/siderolabs/talos/latest).

## Usage

```hcl
module "cluster" {
  source  = "jfreed-dev/modules/turingpi//modules/talos-cluster"
  version = ">= 1.2.4"

  cluster_name     = "my-cluster"
  cluster_endpoint = "https://192.168.1.101:6443"

  # Pin versions to match your Talos image
  talos_version      = "v1.9.2"
  kubernetes_version = "v1.32.1"

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

### With NVMe Storage (for Longhorn)

```hcl
module "cluster" {
  source  = "jfreed-dev/modules/turingpi//modules/talos-cluster"
  version = ">= 1.2.4"

  cluster_name     = "my-cluster"
  cluster_endpoint = "https://192.168.1.101:6443"

  talos_version      = "v1.9.2"
  kubernetes_version = "v1.32.1"

  control_plane = [{ host = "192.168.1.101" }]
  workers = [
    { host = "192.168.1.102" },
    { host = "192.168.1.103" },
    { host = "192.168.1.104" }
  ]

  # Enable NVMe storage for Longhorn
  nvme_storage_enabled = true
  nvme_device          = "/dev/nvme0n1"
  nvme_mountpoint      = "/var/mnt/longhorn"
  nvme_control_plane   = true  # Also configure NVMe on control plane

  kubeconfig_path  = "./kubeconfig"
  talosconfig_path = "./talosconfig"
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
| talos_version | Talos version for config generation (e.g., 'v1.9.2'). Must match Talos image on nodes. | `string` | `null` | no |
| kubernetes_version | Kubernetes version (e.g., 'v1.32.1'). Must be compatible with the Talos version. | `string` | `null` | no |
| controlplane_patches | Config patches for control plane nodes (YAML strings) | `list(string)` | `[]` | no |
| worker_patches | Config patches for worker nodes (YAML strings) | `list(string)` | `[]` | no |
| kubeconfig_path | Path to write kubeconfig file | `string` | `null` | no |
| talosconfig_path | Path to write talosconfig file | `string` | `null` | no |
| allow_scheduling_on_control_plane | Allow workloads on control plane nodes | `bool` | `true` | no |
| nvme_storage_enabled | Enable NVMe storage configuration for Longhorn | `bool` | `false` | no |
| nvme_device | NVMe device path | `string` | `"/dev/nvme0n1"` | no |
| nvme_mountpoint | Mount point for NVMe storage | `string` | `"/var/mnt/longhorn"` | no |
| nvme_control_plane | Configure NVMe on control plane nodes | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| kubeconfig | Kubeconfig for cluster access (sensitive) |
| client_configuration | Talos client configuration for talosctl (sensitive) |
| machine_secrets | Talos machine secrets for backup (sensitive) |
| cluster_endpoint | Kubernetes API endpoint |
| cluster_name | Cluster name |
| kubeconfig_path | Path to kubeconfig file (if written) |
| nvme_enabled | Whether NVMe storage is configured |
| nvme_mountpoint | NVMe mount point (if enabled) |

## NVMe Storage Configuration

When `nvme_storage_enabled = true`, the module automatically generates Talos machine configuration patches to:

1. Partition the NVMe device
2. Mount it at the specified mountpoint
3. Make it available for Longhorn distributed storage

This is equivalent to applying the following Talos config patch:

```yaml
machine:
  disks:
    - device: /dev/nvme0n1
      partitions:
        - mountpoint: /var/mnt/longhorn
```

### Using with Longhorn

After enabling NVMe storage, configure Longhorn to use it:

```hcl
module "longhorn" {
  source  = "jfreed-dev/modules/turingpi//modules/addons/longhorn"
  version = ">= 1.2.4"

  depends_on = [module.cluster]

  default_data_path         = "/var/mnt/longhorn"
  create_nvme_storage_class = true
  nvme_replica_count        = 2
}
```

## Prerequisites

Nodes must be pre-flashed with Talos Linux. Use the [flash-nodes](../flash-nodes) module or the `turingpi_flash` resource.

## License

Apache 2.0 - See [LICENSE](../../LICENSE) for details.
