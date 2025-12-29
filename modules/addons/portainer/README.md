# Portainer Agent Module

Terraform module to deploy the [Portainer](https://www.portainer.io/) agent for remote cluster management.

The agent allows you to connect this Kubernetes cluster to a Portainer CE (Community Edition) or Business Edition instance for visual management.

## Usage

```hcl
module "portainer" {
  source  = "jfreed-dev/modules/turingpi//modules/addons/portainer"
  version = ">= 1.2.0"

  # Use LoadBalancer with MetalLB
  service_type    = "LoadBalancer"
  loadbalancer_ip = "192.168.1.81"

  # Or use NodePort
  # service_type = "NodePort"
  # node_port    = 30778
}
```

Then connect from your Portainer instance using the agent URL.

## Requirements

| Name | Version |
|------|---------:|
| terraform | >= 1.0 |
| kubectl | >= 1.14 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| agent_version | Portainer agent version | `string` | `"2.24.1"` | no |
| service_type | Service type (NodePort or LoadBalancer) | `string` | `"LoadBalancer"` | no |
| loadbalancer_ip | LoadBalancer IP for MetalLB | `string` | `null` | no |
| node_port | NodePort port number | `number` | `30778` | no |
| log_level | Agent log level | `string` | `"INFO"` | no |
| memory_request | Memory request | `string` | `"64Mi"` | no |
| memory_limit | Memory limit | `string` | `"256Mi"` | no |
| cpu_request | CPU request | `string` | `"50m"` | no |
| cpu_limit | CPU limit | `string` | `"500m"` | no |

## Outputs

| Name | Description |
|------|-------------|
| namespace | Portainer namespace |
| service_name | Agent service name |
| service_type | Service type |
| agent_port | Agent port (9001) |
| node_port | NodePort (if applicable) |
| loadbalancer_ip | LoadBalancer IP (if specified) |
| connection_url | URL to connect from Portainer |
| agent_version | Deployed agent version |

## Connecting to Portainer

### Portainer Community Edition (CE)

Portainer CE is free and open-source. You can run it anywhere:

1. **Self-hosted Portainer CE:**
   ```bash
   docker run -d -p 9443:9443 --name portainer \
     --restart=always \
     -v /var/run/docker.sock:/var/run/docker.sock \
     -v portainer_data:/data \
     portainer/portainer-ce:latest
   ```

2. **Connect your cluster:**
   - Go to **Environments** > **Add environment**
   - Select **Agent**
   - Enter the connection URL:
     - LoadBalancer: `<loadbalancer_ip>:9001`
     - NodePort: `<any_node_ip>:30778`
   - Give the environment a name
   - Click **Connect**

### Portainer Business Edition

Portainer Business Edition includes additional features like RBAC, registry management, and GitOps. It requires a license.

1. **Get a license:**
   - Free for up to 5 nodes: [portainer.io/take-5](https://www.portainer.io/take-5)
   - Purchase: [portainer.io/pricing](https://www.portainer.io/pricing)

2. **Deploy Portainer BE:**
   ```bash
   docker run -d -p 9443:9443 --name portainer \
     --restart=always \
     -v /var/run/docker.sock:/var/run/docker.sock \
     -v portainer_data:/data \
     portainer/portainer-ee:latest
   ```

3. **Connect your cluster:**
   - Enter your license key on first login
   - Go to **Environments** > **Add environment**
   - Select **Agent**
   - Enter the connection URL:
     - LoadBalancer: `<loadbalancer_ip>:9001`
     - NodePort: `<any_node_ip>:30778`
   - Give the environment a name
   - Click **Connect**

### Business Edition Features

If you have a Business Edition license, you can take advantage of:
- **Role-Based Access Control (RBAC)** - Fine-grained permissions
- **Registry Management** - Manage multiple container registries
- **GitOps Deployments** - Deploy from Git repositories
- **Edge Compute** - Manage edge environments
- **Activity Logs** - Audit trail of all actions
- **External Authentication** - LDAP, OAuth, Azure AD

## Example with MetalLB

```hcl
module "metallb" {
  source   = "jfreed-dev/modules/turingpi//modules/addons/metallb"
  ip_range = "192.168.1.80-192.168.1.89"
}

module "portainer" {
  source          = "jfreed-dev/modules/turingpi//modules/addons/portainer"
  depends_on      = [module.metallb]
  loadbalancer_ip = "192.168.1.81"
}

output "portainer_url" {
  value = module.portainer.connection_url
}
```

## Full Stack Example

```hcl
# Deploy Talos cluster
module "cluster" {
  source  = "jfreed-dev/modules/turingpi//modules/talos-cluster"
  version = ">= 1.2.0"

  cluster_name     = "homelab"
  cluster_endpoint = "https://192.168.1.101:6443"
  control_plane    = [{ host = "192.168.1.101" }]
  workers = [
    { host = "192.168.1.102" },
    { host = "192.168.1.103" },
    { host = "192.168.1.104" }
  ]
  kubeconfig_path = "./kubeconfig"
}

# Deploy MetalLB for LoadBalancer support
module "metallb" {
  source     = "jfreed-dev/modules/turingpi//modules/addons/metallb"
  depends_on = [module.cluster]
  ip_range   = "192.168.1.200-192.168.1.220"
}

# Deploy Portainer agent
module "portainer" {
  source          = "jfreed-dev/modules/turingpi//modules/addons/portainer"
  depends_on      = [module.metallb]
  loadbalancer_ip = "192.168.1.201"
}

output "portainer_connection" {
  description = "Connect Portainer to this URL"
  value       = module.portainer.connection_url
}
```

## License

Apache 2.0 - See [LICENSE](../../../LICENSE) for details.
