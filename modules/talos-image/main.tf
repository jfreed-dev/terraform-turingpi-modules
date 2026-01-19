locals {
  # Preset extension bundles
  preset_extensions = {
    none         = []
    longhorn     = ["siderolabs/iscsi-tools", "siderolabs/util-linux-tools"]
    longhorn-nfs = ["siderolabs/iscsi-tools", "siderolabs/util-linux-tools", "siderolabs/nfs-utils"]
    qemu         = ["siderolabs/qemu-guest-agent"]
    full         = ["siderolabs/iscsi-tools", "siderolabs/util-linux-tools", "siderolabs/nfs-utils", "siderolabs/qemu-guest-agent"]
  }

  # Merge preset extensions with custom extensions
  all_extensions = distinct(concat(
    local.preset_extensions[var.preset],
    var.extensions
  ))

  # Build the schematic YAML
  schematic_yaml = yamlencode({
    customization = {
      systemExtensions = length(local.all_extensions) > 0 ? {
        officialExtensions = local.all_extensions
      } : null
      extraKernelArgs = length(var.extra_kernel_args) > 0 ? var.extra_kernel_args : null
    }
  })

  # Known schematic IDs for common configurations (saves API calls)
  known_schematics = {
    # iscsi-tools + util-linux-tools (Longhorn support)
    "siderolabs/iscsi-tools,siderolabs/util-linux-tools" = "613e1592b2da41ae5e265e8789429f22e121aab91cb4deb6bc3c0b6262961245"
  }

  # Check if we have a known schematic ID
  extensions_key   = join(",", sort(local.all_extensions))
  known_schematic  = lookup(local.known_schematics, local.extensions_key, null)
  use_known        = local.known_schematic != null
}

# Create schematic via Image Factory API (only if not using known schematic)
resource "terraform_data" "schematic" {
  count = local.use_known ? 0 : 1

  input = local.schematic_yaml

  provisioner "local-exec" {
    command = <<-EOF
      curl -s -X POST ${var.image_factory_url}/schematics \
        -H "Content-Type: application/yaml" \
        --data-binary '${local.schematic_yaml}' \
        > ${path.module}/.schematic-response.json
    EOF
  }
}

# Read the schematic response
data "local_file" "schematic_response" {
  count      = local.use_known ? 0 : 1
  depends_on = [terraform_data.schematic]

  filename = "${path.module}/.schematic-response.json"
}

locals {
  # Parse schematic ID from API response or use known ID
  schematic_id = local.use_known ? local.known_schematic : try(
    jsondecode(data.local_file.schematic_response[0].content).id,
    null
  )

  # Build image URLs
  image_base_url = "${var.image_factory_url}/image/${local.schematic_id}/${var.talos_version}"
}
