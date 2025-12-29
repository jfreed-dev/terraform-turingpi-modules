# Turing Pi Flash Nodes Module

Terraform module to flash firmware to Turing Pi 2.5 nodes.

## Usage

```hcl
module "flash" {
  source  = "jfreed-dev/flash-nodes/turingpi"
  version = ">= 1.2.0"

  nodes = {
    1 = { firmware = "/path/to/talos-arm64.raw" }
    2 = { firmware = "/path/to/talos-arm64.raw" }
    3 = { firmware = "/path/to/talos-arm64.raw" }
    4 = { firmware = "/path/to/talos-arm64.raw" }
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| turingpi | >= 1.2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| nodes | Map of node number to firmware configuration | `map(object({ firmware = string }))` | n/a | yes |
| power_on_after_flash | Power on nodes after flashing | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| flashed_nodes | List of flashed node numbers |

## License

Apache 2.0 - See [LICENSE](../../LICENSE) for details.
