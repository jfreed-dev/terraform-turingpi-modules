variable "nodes" {
  description = "Map of node number to firmware configuration"
  type = map(object({
    firmware = string
  }))
}

variable "power_on_after_flash" {
  description = "Power on nodes after flashing"
  type        = bool
  default     = true
}
