variable "chart_version" {
  description = "cert-manager Helm chart version"
  type        = string
  default     = "1.16.2"
}

variable "namespace" {
  description = "Kubernetes namespace for cert-manager"
  type        = string
  default     = "cert-manager"
}

variable "timeout" {
  description = "Helm install timeout in seconds"
  type        = number
  default     = 300
}

variable "install_crds" {
  description = "Install cert-manager CRDs"
  type        = bool
  default     = true
}

# Let's Encrypt Configuration
variable "create_letsencrypt_issuer" {
  description = "Create Let's Encrypt ClusterIssuer"
  type        = bool
  default     = false
}

variable "letsencrypt_email" {
  description = "Email for Let's Encrypt registration"
  type        = string
  default     = ""
}

variable "letsencrypt_server" {
  description = "Let's Encrypt server (staging or production)"
  type        = string
  default     = "production"

  validation {
    condition     = contains(["staging", "production"], var.letsencrypt_server)
    error_message = "Let's Encrypt server must be 'staging' or 'production'."
  }
}

# Self-signed CA Configuration
variable "create_selfsigned_issuer" {
  description = "Create self-signed ClusterIssuer for internal certificates"
  type        = bool
  default     = true
}

# Resource Configuration
variable "controller_resources" {
  description = "Resource requests/limits for cert-manager controller"
  type = object({
    requests = optional(object({
      cpu    = optional(string, "50m")
      memory = optional(string, "64Mi")
    }), {})
    limits = optional(object({
      cpu    = optional(string, "200m")
      memory = optional(string, "256Mi")
    }), {})
  })
  default = {}
}

variable "webhook_resources" {
  description = "Resource requests/limits for cert-manager webhook"
  type = object({
    requests = optional(object({
      cpu    = optional(string, "25m")
      memory = optional(string, "32Mi")
    }), {})
    limits = optional(object({
      cpu    = optional(string, "100m")
      memory = optional(string, "128Mi")
    }), {})
  })
  default = {}
}

variable "cainjector_resources" {
  description = "Resource requests/limits for cert-manager cainjector"
  type = object({
    requests = optional(object({
      cpu    = optional(string, "25m")
      memory = optional(string, "64Mi")
    }), {})
    limits = optional(object({
      cpu    = optional(string, "100m")
      memory = optional(string, "256Mi")
    }), {})
  })
  default = {}
}

# Replica Configuration
variable "controller_replicas" {
  description = "Number of cert-manager controller replicas"
  type        = number
  default     = 1
}

variable "webhook_replicas" {
  description = "Number of cert-manager webhook replicas"
  type        = number
  default     = 1
}

# DNS01 Challenge Configuration (for wildcard certs)
variable "dns01_enabled" {
  description = "Enable DNS01 challenge support"
  type        = bool
  default     = false
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token for DNS01 challenges"
  type        = string
  sensitive   = true
  default     = ""
}

variable "cloudflare_email" {
  description = "Cloudflare account email"
  type        = string
  default     = ""
}
