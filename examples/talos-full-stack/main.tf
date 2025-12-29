# Example: Full Talos cluster with MetalLB and Ingress-NGINX on Turing Pi

# Configure Turing Pi provider
provider "turingpi" {
  endpoint = var.turingpi_endpoint
  username = var.turingpi_username
  password = var.turingpi_password
}

# Flash Talos to all nodes
module "flash" {
  source = "../../modules/flash-nodes"

  nodes = {
    1 = { firmware = var.talos_firmware }
    2 = { firmware = var.talos_firmware }
    3 = { firmware = var.talos_firmware }
    4 = { firmware = var.talos_firmware }
  }
}

# Wait for nodes to boot after flashing
resource "time_sleep" "wait_for_boot" {
  depends_on      = [module.flash]
  create_duration = "120s"
}

# Deploy Talos cluster
module "cluster" {
  source     = "../../modules/talos-cluster"
  depends_on = [time_sleep.wait_for_boot]

  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.control_plane_ip}:6443"

  control_plane = [{ host = var.control_plane_ip }]
  workers = [
    { host = var.worker_ips[0] },
    { host = var.worker_ips[1] },
    { host = var.worker_ips[2] }
  ]

  kubeconfig_path  = "${path.module}/kubeconfig"
  talosconfig_path = "${path.module}/talosconfig"

  allow_scheduling_on_control_plane = true
}

# Configure providers for addons using generated kubeconfig
provider "helm" {
  kubernetes {
    config_path = module.cluster.kubeconfig_path
  }
}

provider "kubectl" {
  config_path = module.cluster.kubeconfig_path
}

# Deploy MetalLB
module "metallb" {
  source     = "../../modules/addons/metallb"
  depends_on = [module.cluster]

  ip_range = var.metallb_ip_range
}

# Deploy Ingress-NGINX
module "ingress" {
  source     = "../../modules/addons/ingress-nginx"
  depends_on = [module.metallb]

  loadbalancer_ip = var.ingress_ip
}
