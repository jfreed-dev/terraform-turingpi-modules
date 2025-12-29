variable "agent_version" {
  description = "Portainer agent version"
  type        = string
  default     = "2.24.1"
}

variable "service_type" {
  description = "Service type: NodePort or LoadBalancer"
  type        = string
  default     = "LoadBalancer"

  validation {
    condition     = contains(["NodePort", "LoadBalancer"], var.service_type)
    error_message = "Service type must be NodePort or LoadBalancer."
  }
}

variable "loadbalancer_ip" {
  description = "LoadBalancer IP (for MetalLB, optional)"
  type        = string
  default     = null
}

variable "node_port" {
  description = "NodePort port number (when service_type is NodePort)"
  type        = number
  default     = 30778
}

variable "log_level" {
  description = "Agent log level (DEBUG, INFO, WARN, ERROR)"
  type        = string
  default     = "INFO"
}

# Resource limits
variable "memory_request" {
  description = "Memory request"
  type        = string
  default     = "64Mi"
}

variable "memory_limit" {
  description = "Memory limit"
  type        = string
  default     = "256Mi"
}

variable "cpu_request" {
  description = "CPU request"
  type        = string
  default     = "50m"
}

variable "cpu_limit" {
  description = "CPU limit"
  type        = string
  default     = "500m"
}
