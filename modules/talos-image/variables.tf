variable "talos_version" {
  description = "Talos version (e.g., 'v1.9.2')"
  type        = string
}

variable "architecture" {
  description = "Target architecture"
  type        = string
  default     = "arm64"

  validation {
    condition     = contains(["arm64", "amd64"], var.architecture)
    error_message = "Architecture must be 'arm64' or 'amd64'."
  }
}

variable "platform" {
  description = "Target platform (metal, aws, gcp, azure, etc.)"
  type        = string
  default     = "metal"
}

variable "extensions" {
  description = "List of official Talos extensions to include"
  type        = list(string)
  default     = []
}

variable "extra_kernel_args" {
  description = "Extra kernel arguments to include"
  type        = list(string)
  default     = []
}

variable "image_factory_url" {
  description = "Talos Image Factory base URL"
  type        = string
  default     = "https://factory.talos.dev"
}

# Preset extension bundles
variable "preset" {
  description = "Preset extension bundle: 'longhorn' (iscsi-tools, util-linux-tools), 'longhorn-nfs' (adds nfs-utils), 'qemu' (qemu-guest-agent), or 'none'"
  type        = string
  default     = "none"

  validation {
    condition     = contains(["none", "longhorn", "longhorn-nfs", "qemu", "full"], var.preset)
    error_message = "Preset must be 'none', 'longhorn', 'longhorn-nfs', 'qemu', or 'full'."
  }
}
