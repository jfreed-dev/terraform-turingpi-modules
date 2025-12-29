variable "ip_range" {
  description = "IP range for LoadBalancer services (e.g., 192.168.1.200-192.168.1.220)"
  type        = string
}

variable "pool_name" {
  description = "Name of the IP address pool"
  type        = string
  default     = "default-pool"
}

variable "chart_version" {
  description = "MetalLB Helm chart version"
  type        = string
  default     = "0.14.9"
}

variable "timeout" {
  description = "Helm install timeout in seconds"
  type        = number
  default     = 300
}
