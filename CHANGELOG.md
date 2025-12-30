# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.7] - 2025-12-30

### Added
- terraform-docs integration for auto-generated module documentation
- `.terraform-docs.yml` configuration file
- GitHub Actions workflow to auto-update docs on PRs

## [1.2.6] - 2025-12-30

### Added
- Trivy security scanning in CI workflow
- `trivy.yaml` configuration for Terraform misconfiguration scanning

## [1.2.5] - 2025-12-30

### Added
- CODEOWNERS file for automatic PR review requests
- GitHub Actions workflow for Terraform validation on PRs
- TFLint integration with recommended ruleset
- Branch protection with required status checks

### Removed
- Unused `install_timeout` variable from k3s-cluster module
- Unused `allow_scheduling_on_control_plane` variable from talos-cluster module

## [1.2.4] - 2025-12-30

### Added
- `talos_version` variable to talos-cluster module for explicit Talos version in config generation
- `kubernetes_version` variable to talos-cluster module for explicit Kubernetes version

## [1.2.3] - 2025-12-30

### Changed
- Updated provider requirement to `>= 1.3.0` (includes BMC API compatibility and flash implementation)
- Updated all documentation examples to reference v1.3.0

## [1.2.2] - 2025-12-29

### Changed
- Updated all module version references to `>= 1.2.0`
- Updated provider requirement to `>= 1.2.0`
- Added k3s-cluster, longhorn, monitoring, portainer to available_submodules list
- Synchronized documentation with terraform-provider-turingpi repo

## [1.2.1] - 2025-12-29

### Fixed
- Applied terraform fmt formatting fixes across all modules

## [1.2.0] - 2025-12-29

### Added
- **k3s-cluster module** - Deploy K3s Kubernetes cluster on Armbian
  - SSH-based deployment (key or password authentication)
  - NVMe storage configuration for Longhorn
  - Automatic package installation (open-iscsi, nfs-common)
  - Configurable K3s options (disable traefik, servicelb, etc.)

- **k3s-full-stack example** - Complete K3s deployment with all addons

### Changed
- Updated talos-full-stack example with all addon modules
- Updated root README with K3s quick start and Talos vs K3s comparison

## [1.1.0] - 2025-12-29

### Added
- **Addon modules**
  - `longhorn` - Distributed block storage with NVMe-optimized storage class
  - `monitoring` - Prometheus, Grafana, Alertmanager (kube-prometheus-stack)
  - `portainer` - Cluster management agent for CE/BE

- **NVMe storage support** for talos-cluster module
  - `nvme_storage_enabled` - Enable NVMe configuration
  - `nvme_device` - Device path configuration
  - `nvme_mountpoint` - Mount point for Longhorn
  - `nvme_control_plane` - Configure NVMe on control plane nodes

- **talos-full-stack example** - Complete Talos deployment with all addons

### Changed
- Updated talos-cluster module with NVMe configuration options
- Enhanced README with full stack examples

## [1.0.4] - 2025-12-29

### Fixed
- Version constraint updates in examples

## [1.0.3] - 2025-12-29

### Fixed
- Duplicate terraform block in flash-nodes module

## [1.0.2] - 2025-12-29

### Added
- Root module configuration for Terraform Registry compatibility

## [1.0.1] - 2025-12-29

### Added
- Module README files for all submodules
- versions.tf files for Terraform Registry compatibility

## [1.0.0] - 2025-12-29

### Added
- Initial release
- **flash-nodes module** - Flash firmware to Turing Pi nodes
- **talos-cluster module** - Deploy Talos Kubernetes cluster
- **metallb addon** - MetalLB load balancer
- **ingress-nginx addon** - NGINX Ingress controller

[Unreleased]: https://github.com/jfreed-dev/terraform-turingpi-modules/compare/v1.2.7...HEAD
[1.2.7]: https://github.com/jfreed-dev/terraform-turingpi-modules/compare/v1.2.6...v1.2.7
[1.2.6]: https://github.com/jfreed-dev/terraform-turingpi-modules/compare/v1.2.5...v1.2.6
[1.2.5]: https://github.com/jfreed-dev/terraform-turingpi-modules/compare/v1.2.4...v1.2.5
[1.2.4]: https://github.com/jfreed-dev/terraform-turingpi-modules/compare/v1.2.3...v1.2.4
[1.2.3]: https://github.com/jfreed-dev/terraform-turingpi-modules/compare/v1.2.2...v1.2.3
[1.2.2]: https://github.com/jfreed-dev/terraform-turingpi-modules/compare/v1.2.1...v1.2.2
[1.2.1]: https://github.com/jfreed-dev/terraform-turingpi-modules/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/jfreed-dev/terraform-turingpi-modules/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/jfreed-dev/terraform-turingpi-modules/compare/v1.0.4...v1.1.0
[1.0.4]: https://github.com/jfreed-dev/terraform-turingpi-modules/compare/v1.0.3...v1.0.4
[1.0.3]: https://github.com/jfreed-dev/terraform-turingpi-modules/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/jfreed-dev/terraform-turingpi-modules/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/jfreed-dev/terraform-turingpi-modules/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/jfreed-dev/terraform-turingpi-modules/releases/tag/v1.0.0
