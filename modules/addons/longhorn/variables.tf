variable "chart_version" {
  description = "Longhorn Helm chart version"
  type        = string
  default     = "1.7.2"
}

variable "timeout" {
  description = "Helm install timeout in seconds"
  type        = number
  default     = 600
}

variable "default_replica_count" {
  description = "Default number of replicas for volumes (1-3)"
  type        = number
  default     = 2

  validation {
    condition     = var.default_replica_count >= 1 && var.default_replica_count <= 3
    error_message = "Replica count must be between 1 and 3."
  }
}

variable "default_data_path" {
  description = "Default data path for Longhorn storage"
  type        = string
  default     = "/var/lib/longhorn"
}

variable "set_default_storage_class" {
  description = "Set Longhorn as the default storage class"
  type        = bool
  default     = true
}

# NVMe Storage Class Options
variable "create_nvme_storage_class" {
  description = "Create an NVMe-optimized storage class with disk selector"
  type        = bool
  default     = false
}

variable "nvme_replica_count" {
  description = "Replica count for NVMe storage class (typically lower for performance)"
  type        = number
  default     = 2
}

variable "set_nvme_as_default" {
  description = "Set NVMe storage class as default instead of standard Longhorn"
  type        = bool
  default     = false
}

# Backup Configuration (Optional)
variable "backup_target" {
  description = "Backup target URL (e.g., s3://bucket@region/path)"
  type        = string
  default     = null
}

variable "backup_target_credential_secret" {
  description = "Secret name containing backup credentials"
  type        = string
  default     = null
}

# Ingress Configuration (Optional)
variable "ingress_enabled" {
  description = "Enable Ingress for Longhorn UI"
  type        = bool
  default     = false
}

variable "ingress_host" {
  description = "Hostname for Longhorn UI Ingress"
  type        = string
  default     = "longhorn.local"
}

variable "ingress_annotations" {
  description = "Additional annotations for Longhorn Ingress"
  type        = map(string)
  default     = {}
}
