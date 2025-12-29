output "flashed_nodes" {
  description = "Map of nodes that were flashed"
  value       = { for k, v in turingpi_flash.nodes : k => v.firmware_file }
}

output "powered_nodes" {
  description = "Map of nodes that were powered on"
  value       = { for k, v in turingpi_power.nodes : k => v.state }
}
