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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.0 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 1.14 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.0 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | >= 1.14 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backup_target"></a> [backup\_target](#input\_backup\_target) | Backup target URL (e.g., s3://bucket@region/path) | `string` | `null` | no |
| <a name="input_backup_target_credential_secret"></a> [backup\_target\_credential\_secret](#input\_backup\_target\_credential\_secret) | Secret name containing backup credentials | `string` | `null` | no |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | Longhorn Helm chart version | `string` | `"1.7.2"` | no |
| <a name="input_create_nvme_storage_class"></a> [create\_nvme\_storage\_class](#input\_create\_nvme\_storage\_class) | Create an NVMe-optimized storage class with disk selector | `bool` | `false` | no |
| <a name="input_default_data_path"></a> [default\_data\_path](#input\_default\_data\_path) | Default data path for Longhorn storage | `string` | `"/var/lib/longhorn"` | no |
| <a name="input_default_replica_count"></a> [default\_replica\_count](#input\_default\_replica\_count) | Default number of replicas for volumes (1-3) | `number` | `2` | no |
| <a name="input_ingress_annotations"></a> [ingress\_annotations](#input\_ingress\_annotations) | Additional annotations for Longhorn Ingress | `map(string)` | `{}` | no |
| <a name="input_ingress_enabled"></a> [ingress\_enabled](#input\_ingress\_enabled) | Enable Ingress for Longhorn UI | `bool` | `false` | no |
| <a name="input_ingress_host"></a> [ingress\_host](#input\_ingress\_host) | Hostname for Longhorn UI Ingress | `string` | `"longhorn.local"` | no |
| <a name="input_nvme_replica_count"></a> [nvme\_replica\_count](#input\_nvme\_replica\_count) | Replica count for NVMe storage class (typically lower for performance) | `number` | `2` | no |
| <a name="input_set_default_storage_class"></a> [set\_default\_storage\_class](#input\_set\_default\_storage\_class) | Set Longhorn as the default storage class | `bool` | `true` | no |
| <a name="input_set_nvme_as_default"></a> [set\_nvme\_as\_default](#input\_set\_nvme\_as\_default) | Set NVMe storage class as default instead of standard Longhorn | `bool` | `false` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Helm install timeout in seconds | `number` | `600` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_chart_version"></a> [chart\_version](#output\_chart\_version) | Deployed Longhorn chart version |
| <a name="output_default_storage_class"></a> [default\_storage\_class](#output\_default\_storage\_class) | Default storage class name |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Longhorn namespace |
| <a name="output_nvme_storage_class"></a> [nvme\_storage\_class](#output\_nvme\_storage\_class) | NVMe storage class name (if created) |
| <a name="output_ui_url"></a> [ui\_url](#output\_ui\_url) | Longhorn UI URL (if ingress enabled) |
<!-- END_TF_DOCS -->

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
