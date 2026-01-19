output "schematic_id" {
  description = "Talos Image Factory schematic ID"
  value       = local.schematic_id
}

output "schematic_yaml" {
  description = "Schematic YAML sent to Image Factory"
  value       = local.schematic_yaml
}

output "extensions" {
  description = "List of extensions included in the image"
  value       = local.all_extensions
}

output "image_url" {
  description = "URL to download the Talos image (raw format)"
  value       = local.schematic_id != null ? "${local.image_base_url}/${var.platform}-${var.architecture}.raw.xz" : null
}

output "image_url_iso" {
  description = "URL to download the Talos ISO image"
  value       = local.schematic_id != null ? "${local.image_base_url}/${var.platform}-${var.architecture}.iso" : null
}

output "installer_url" {
  description = "Talos installer image URL for upgrades"
  value       = local.schematic_id != null ? "factory.talos.dev/installer/${local.schematic_id}:${var.talos_version}" : null
}

output "image_base_url" {
  description = "Base URL for all image formats"
  value       = local.schematic_id != null ? local.image_base_url : null
}

output "download_command" {
  description = "curl command to download the image"
  value       = local.schematic_id != null ? "curl -LO ${local.image_base_url}/${var.platform}-${var.architecture}.raw.xz" : null
}

output "sbc_overlay" {
  description = "SBC overlay name (if configured)"
  value       = var.sbc_overlay
}

output "sbc_overlay_image" {
  description = "SBC overlay image (if configured)"
  value       = local.resolved_overlay_image
}
