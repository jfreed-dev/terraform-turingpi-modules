variable "loadbalancer_ip" {
  description = "Static IP for ingress LoadBalancer (optional)"
  type        = string
  default     = null
}

variable "chart_version" {
  description = "Ingress-NGINX Helm chart version"
  type        = string
  default     = "4.11.3"
}

variable "timeout" {
  description = "Helm install timeout in seconds"
  type        = number
  default     = 300
}

variable "enable_admission_webhooks" {
  description = "Enable admission webhooks"
  type        = bool
  default     = true
}

variable "default_ingress_class" {
  description = "Make this the default ingress class"
  type        = bool
  default     = true
}
