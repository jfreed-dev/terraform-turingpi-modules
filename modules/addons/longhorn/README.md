# Longhorn Distributed Storage Module

Terraform module to deploy [Longhorn](https://longhorn.io/) distributed block storage on a Kubernetes cluster.

## Usage

```hcl
module "longhorn" {
  source  = "jfreed-dev/modules/turingpi//modules/addons/longhorn"
  version = ">= 1.2.0"

  # Basic configuration
  default_replica_count = 2

  # Optional: NVMe-optimized storage class
  # create_nvme_storage_class = true
  # nvme_replica_count        = 2

  # Optional: Ingress for UI access
  # ingress_enabled = true
  # ingress_host    = "longhorn.local"

  # Optional: S3 backup target
  # backup_target                   = "s3://my-bucket@us-east-1/longhorn-backup"
  # backup_target_credential_secret = "longhorn-backup-secret"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| helm | >= 2.0 |
| kubectl | >= 1.14 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| chart_version | Longhorn Helm chart version | `string` | `"1.7.2"` | no |
| timeout | Helm install timeout in seconds | `number` | `600` | no |
| default_replica_count | Default number of replicas (1-3) | `number` | `2` | no |
| default_data_path | Default storage path | `string` | `"/var/lib/longhorn"` | no |
| set_default_storage_class | Set as default storage class | `bool` | `true` | no |
| create_nvme_storage_class | Create NVMe-optimized storage class | `bool` | `false` | no |
| nvme_replica_count | Replicas for NVMe storage class | `number` | `2` | no |
| set_nvme_as_default | Set NVMe class as default | `bool` | `false` | no |
| backup_target | S3 backup target URL | `string` | `null` | no |
| backup_target_credential_secret | Backup credentials secret name | `string` | `null` | no |
| ingress_enabled | Enable Ingress for UI | `bool` | `false` | no |
| ingress_host | Hostname for UI Ingress | `string` | `"longhorn.local"` | no |
| ingress_annotations | Additional Ingress annotations | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| namespace | Longhorn namespace |
| chart_version | Deployed chart version |
| default_storage_class | Default storage class name |
| nvme_storage_class | NVMe storage class name (if created) |
| ui_url | Longhorn UI URL (if ingress enabled) |

## NVMe Storage Configuration

For nodes with NVMe drives, you can create an optimized storage class:

```hcl
module "longhorn" {
  source = "jfreed-dev/modules/turingpi//modules/addons/longhorn"

  create_nvme_storage_class = true
  nvme_replica_count        = 2  # Lower replica count for performance

  # Optionally set NVMe as the default
  # set_nvme_as_default = true
}
```

After deployment, tag your NVMe disks in Longhorn UI or via API:
- Add tag `nvme` to NVMe disk nodes

## License

Apache 2.0 - See [LICENSE](../../../LICENSE) for details.
