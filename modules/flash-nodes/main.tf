terraform {
  required_version = ">= 1.0"
  required_providers {
    turingpi = {
      source  = "jfreed-dev/turingpi"
      version = ">= 1.0"
    }
  }
}

resource "turingpi_flash" "nodes" {
  for_each = var.nodes

  node          = each.key
  firmware_file = each.value.firmware
}

resource "turingpi_power" "nodes" {
  for_each   = var.power_on_after_flash ? var.nodes : {}
  depends_on = [turingpi_flash.nodes]

  node  = each.key
  state = "on"
}
