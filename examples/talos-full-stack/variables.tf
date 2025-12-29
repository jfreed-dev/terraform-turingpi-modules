# Turing Pi BMC connection
variable "turingpi_endpoint" {
  description = "Turing Pi BMC endpoint"
  type        = string
  default     = "https://turingpi.local"
}

variable "turingpi_username" {
  description = "Turing Pi BMC username"
  type        = string
  default     = "root"
}

variable "turingpi_password" {
  description = "Turing Pi BMC password"
  type        = string
  sensitive   = true
}

# Firmware configuration
variable "talos_firmware" {
  description = "Path to Talos firmware image"
  type        = string
}

# Cluster configuration
variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
  default     = "turing-cluster"
}

variable "control_plane_ip" {
  description = "IP address of the control plane node"
  type        = string
}

variable "worker_ips" {
  description = "IP addresses of worker nodes"
  type        = list(string)
}

# Network configuration
variable "metallb_ip_range" {
  description = "IP range for MetalLB LoadBalancer services"
  type        = string
}

variable "ingress_ip" {
  description = "IP address for ingress controller"
  type        = string
}
