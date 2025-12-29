# K3s Cluster Module

Terraform module to deploy a K3s Kubernetes cluster on Turing Pi 2.5 nodes running Armbian (or other Debian-based distributions).

This module connects to nodes via SSH, prepares them (packages, NVMe storage), and installs K3s using the official installation script.

## Usage

### Basic Cluster (SSH Key)

```hcl
module "k3s" {
  source  = "jfreed-dev/modules/turingpi//modules/k3s-cluster"
  version = ">= 1.0.0"

  cluster_name = "my-cluster"

  control_plane = {
    host     = "192.168.1.101"
    ssh_user = "root"
    ssh_key  = file("~/.ssh/id_rsa")
  }

  workers = [
    {
      host     = "192.168.1.102"
      ssh_user = "root"
      ssh_key  = file("~/.ssh/id_rsa")
    },
    {
      host     = "192.168.1.103"
      ssh_user = "root"
      ssh_key  = file("~/.ssh/id_rsa")
    },
    {
      host     = "192.168.1.104"
      ssh_user = "root"
      ssh_key  = file("~/.ssh/id_rsa")
    }
  ]

  kubeconfig_path = "./kubeconfig"
}
```

### Basic Cluster (SSH Password)

```hcl
module "k3s" {
  source  = "jfreed-dev/modules/turingpi//modules/k3s-cluster"
  version = ">= 1.0.0"

  cluster_name = "my-cluster"

  control_plane = {
    host         = "192.168.1.101"
    ssh_user     = "root"
    ssh_password = var.ssh_password
  }

  workers = [
    {
      host         = "192.168.1.102"
      ssh_user     = "root"
      ssh_password = var.ssh_password
    }
  ]

  kubeconfig_path = "./kubeconfig"
}

variable "ssh_password" {
  type      = string
  sensitive = true
}
```

### With NVMe Storage (for Longhorn)

```hcl
module "k3s" {
  source  = "jfreed-dev/modules/turingpi//modules/k3s-cluster"
  version = ">= 1.0.0"

  cluster_name = "homelab"
  k3s_version  = "v1.31.4+k3s1"

  control_plane = {
    host     = "192.168.1.101"
    ssh_user = "root"
    ssh_key  = file("~/.ssh/id_rsa")
  }

  workers = [
    { host = "192.168.1.102", ssh_user = "root", ssh_key = file("~/.ssh/id_rsa") },
    { host = "192.168.1.103", ssh_user = "root", ssh_key = file("~/.ssh/id_rsa") },
    { host = "192.168.1.104", ssh_user = "root", ssh_key = file("~/.ssh/id_rsa") }
  ]

  # Enable NVMe storage for Longhorn
  nvme_storage_enabled = true
  nvme_device          = "/dev/nvme0n1"
  nvme_mountpoint      = "/var/lib/longhorn"
  nvme_filesystem      = "ext4"
  nvme_control_plane   = true

  # Longhorn prerequisites (enabled by default)
  install_open_iscsi = true
  install_nfs_common = true

  kubeconfig_path = "./kubeconfig"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| null | >= 3.0 |
| local | >= 2.0 |
| random | >= 3.0 |

## Prerequisites

1. **Nodes pre-flashed with Armbian** - Use the [flash-nodes](../flash-nodes) module to flash Armbian
2. **SSH access configured** - SSH key or password authentication
3. **Network connectivity** - Nodes must reach each other and the internet

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | Name of the K3s cluster | `string` | n/a | yes |
| control_plane | Control plane node configuration | `object` | n/a | yes |
| workers | Worker node configurations | `list(object)` | `[]` | no |
| k3s_version | K3s version (e.g., v1.31.4+k3s1) | `string` | `""` (latest) | no |
| cluster_token | Cluster token (auto-generated if empty) | `string` | `""` | no |
| kubeconfig_path | Path to write kubeconfig file | `string` | `null` | no |
| disable_traefik | Disable built-in Traefik | `bool` | `true` | no |
| disable_servicelb | Disable built-in ServiceLB | `bool` | `true` | no |
| disable_local_storage | Disable built-in local-path provisioner | `bool` | `false` | no |
| flannel_backend | Flannel backend type | `string` | `"vxlan"` | no |
| cluster_cidr | Pod CIDR | `string` | `"10.42.0.0/16"` | no |
| service_cidr | Service CIDR | `string` | `"10.43.0.0/16"` | no |
| extra_server_args | Extra K3s server arguments | `list(string)` | `[]` | no |
| extra_agent_args | Extra K3s agent arguments | `list(string)` | `[]` | no |
| nvme_storage_enabled | Enable NVMe storage configuration | `bool` | `false` | no |
| nvme_device | NVMe device path | `string` | `"/dev/nvme0n1"` | no |
| nvme_mountpoint | NVMe mount point | `string` | `"/var/lib/longhorn"` | no |
| nvme_filesystem | NVMe filesystem type | `string` | `"ext4"` | no |
| nvme_control_plane | Configure NVMe on control plane | `bool` | `true` | no |
| install_open_iscsi | Install open-iscsi for Longhorn | `bool` | `true` | no |
| install_nfs_common | Install nfs-common | `bool` | `true` | no |

### Node Configuration Object

```hcl
{
  host         = string           # IP or hostname
  ssh_user     = string           # SSH username
  ssh_key      = optional(string) # SSH private key content
  ssh_password = optional(string) # SSH password
  ssh_port     = optional(number) # SSH port (default: 22)
  hostname     = optional(string) # Custom hostname
}
```

## Outputs

| Name | Description |
|------|-------------|
| kubeconfig | Kubeconfig for cluster access (sensitive) |
| api_endpoint | Kubernetes API endpoint |
| cluster_name | Cluster name |
| cluster_token | Cluster token (sensitive) |
| control_plane_host | Control plane IP |
| worker_hosts | Worker node IPs |
| kubeconfig_path | Path to kubeconfig file |
| nvme_enabled | NVMe storage status |
| nvme_mountpoint | NVMe mount point |
| k3s_version | Installed K3s version |

## K3s Configuration

By default, this module:
- **Disables Traefik** - Use ingress-nginx addon instead
- **Disables ServiceLB** - Use MetalLB addon instead
- **Installs open-iscsi** - Required for Longhorn
- **Installs nfs-common** - For NFS storage support

These defaults are optimized for use with the addon modules (MetalLB, Ingress-NGINX, Longhorn).

## Using with Addons

After cluster creation, deploy addons using the kubeconfig output:

```hcl
# K3s cluster
module "k3s" {
  source = "jfreed-dev/modules/turingpi//modules/k3s-cluster"
  # ... configuration
}

# Configure Kubernetes providers
provider "helm" {
  kubernetes {
    config_path = module.k3s.kubeconfig_path
  }
}

provider "kubectl" {
  config_path = module.k3s.kubeconfig_path
}

# MetalLB for LoadBalancer services
module "metallb" {
  source     = "jfreed-dev/modules/turingpi//modules/addons/metallb"
  depends_on = [module.k3s]
  ip_range   = "192.168.1.200-192.168.1.220"
}

# Ingress NGINX
module "ingress" {
  source          = "jfreed-dev/modules/turingpi//modules/addons/ingress-nginx"
  depends_on      = [module.metallb]
  loadbalancer_ip = "192.168.1.200"
}

# Longhorn storage (with NVMe)
module "longhorn" {
  source            = "jfreed-dev/modules/turingpi//modules/addons/longhorn"
  depends_on        = [module.k3s]
  default_data_path = "/var/lib/longhorn"
}

# Monitoring
module "monitoring" {
  source     = "jfreed-dev/modules/turingpi//modules/addons/monitoring"
  depends_on = [module.longhorn]

  grafana_admin_password = var.grafana_password
  storage_class          = "longhorn"
}

# Portainer
module "portainer" {
  source          = "jfreed-dev/modules/turingpi//modules/addons/portainer"
  depends_on      = [module.metallb]
  loadbalancer_ip = "192.168.1.201"
}
```

## Differences from Talos

| Feature | K3s (Armbian) | Talos |
|---------|---------------|-------|
| OS | Armbian/Debian | Talos Linux |
| Access | SSH | talosctl API |
| Updates | apt + k3s script | Image-based |
| Customization | Full Linux | Limited (secure) |
| NVMe Setup | Partition + mount | Machine config |
| Storage Default | local-path | None |

## Troubleshooting

### SSH Connection Failed
- Verify node is accessible: `ssh root@<ip>`
- Check SSH key permissions: `chmod 600 ~/.ssh/id_rsa`
- Ensure node has completed boot

### K3s Installation Timeout
- Check node internet connectivity
- Verify DNS resolution on nodes
- Review logs: `journalctl -u k3s`

### Worker Not Joining
- Verify control plane is ready
- Check network connectivity between nodes
- Review agent logs: `journalctl -u k3s-agent`

### NVMe Not Detected
- Verify device exists: `lsblk`
- Check NVMe is properly seated
- Device may be `/dev/nvme0n1` or similar

## License

Apache 2.0 - See [LICENSE](../../LICENSE) for details.
