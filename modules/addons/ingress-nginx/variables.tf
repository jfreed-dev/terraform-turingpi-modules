variable "loadbalancer_ip" {
  description = "Static IP for ingress LoadBalancer (optional)"
  type        = string
  default     = null
}

variable "namespace" {
  description = "Kubernetes namespace for ingress-nginx"
  type        = string
  default     = "ingress-nginx"
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

variable "controller_replicas" {
  description = "Number of controller replicas"
  type        = number
  default     = 1
}

variable "controller_resources" {
  description = "Resource requests/limits for ingress controller"
  type = object({
    requests = optional(object({
      cpu    = optional(string, "100m")
      memory = optional(string, "128Mi")
    }), {})
    limits = optional(object({
      cpu    = optional(string, "500m")
      memory = optional(string, "512Mi")
    }), {})
  })
  default = {}
}

variable "enable_metrics" {
  description = "Enable Prometheus metrics"
  type        = bool
  default     = false
}

variable "metrics_port" {
  description = "Port for Prometheus metrics"
  type        = number
  default     = 10254
}
