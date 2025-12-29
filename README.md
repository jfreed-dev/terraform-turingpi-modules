# Terraform Turing Pi Modules

Reusable Terraform modules for Turing Pi cluster provisioning and management.

## Modules

| Module | Description |
|--------|-------------|
| [flash-nodes](./modules/flash-nodes) | Flash firmware to Turing Pi nodes |
| [talos-cluster](./modules/talos-cluster) | Deploy Talos Kubernetes cluster |
| [metallb](./modules/addons/metallb) | MetalLB load balancer addon |
| [ingress-nginx](./modules/addons/ingress-nginx) | NGINX Ingress controller addon |

## Quick Start

```hcl
# Flash Talos to nodes
module "flash" {
  source  = "jfreed-dev/modules/turingpi//modules/flash-nodes"
  version = "1.0.2"

  nodes = {
    1 = { firmware = "talos-rk1-v1.9.1.raw.xz" }
    2 = { firmware = "talos-rk1-v1.9.1.raw.xz" }
    3 = { firmware = "talos-rk1-v1.9.1.raw.xz" }
    4 = { firmware = "talos-rk1-v1.9.1.raw.xz" }
  }
}

# Deploy Talos cluster
module "cluster" {
  source     = "jfreed-dev/modules/turingpi//modules/talos-cluster"
  version    = "1.0.2"
  depends_on = [module.flash]

  cluster_name     = "homelab"
  cluster_endpoint = "https://192.168.1.101:6443"

  control_plane = [{ host = "192.168.1.101" }]
  workers = [
    { host = "192.168.1.102" },
    { host = "192.168.1.103" },
    { host = "192.168.1.104" }
  ]
}

# Deploy MetalLB
module "metallb" {
  source     = "jfreed-dev/modules/turingpi//modules/addons/metallb"
  version    = "1.0.2"
  depends_on = [module.cluster]

  ip_range = "192.168.1.200-192.168.1.220"
}

# Deploy Ingress-NGINX
module "ingress" {
  source          = "jfreed-dev/modules/turingpi//modules/addons/ingress-nginx"
  version         = "1.0.2"
  depends_on      = [module.metallb]

  loadbalancer_ip = "192.168.1.200"
}
```

## Examples

- [talos-full-stack](./examples/talos-full-stack) - Complete Talos cluster with MetalLB and Ingress

## Requirements

- Terraform >= 1.0
- [Turing Pi Terraform Provider](https://github.com/jfreed-dev/terraform-provider-turingpi) >= 1.0
- [Talos Terraform Provider](https://github.com/siderolabs/terraform-provider-talos) >= 0.7

## Migration from turingpi_talos_cluster

If you're migrating from the deprecated `turingpi_talos_cluster` resource:

1. Export your cluster state (secrets, kubeconfig)
2. Remove the old resource from state: `terraform state rm turingpi_talos_cluster.cluster`
3. Import using the new modules
4. Apply the new configuration

See the [migration guide](./docs/MIGRATION.md) for detailed instructions.

## License

Apache License 2.0
