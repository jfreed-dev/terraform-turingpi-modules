# Contributing

Thank you for your interest in contributing to the Terraform Turing Pi Modules!

## Development Setup

### Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.0
- [TFLint](https://github.com/terraform-linters/tflint#installation)
- [Trivy](https://aquasecurity.github.io/trivy/latest/getting-started/installation/)
- [terraform-docs](https://terraform-docs.io/user-guide/installation/)
- [pre-commit](https://pre-commit.com/#install)

### Quick Install (Linux/macOS)

```bash
# TFLint
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# Trivy
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin

# terraform-docs
curl -sSLo ./terraform-docs.tar.gz https://terraform-docs.io/dl/v0.19.0/terraform-docs-v0.19.0-$(uname)-amd64.tar.gz
tar -xzf terraform-docs.tar.gz
chmod +x terraform-docs
sudo mv terraform-docs /usr/local/bin/

# pre-commit
pip install pre-commit
```

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/jfreed-dev/terraform-turingpi-modules.git
   cd terraform-turingpi-modules
   ```

2. Install pre-commit hooks:
   ```bash
   pre-commit install
   ```

3. Initialize TFLint plugins:
   ```bash
   tflint --init --config .tflint.hcl
   ```

## Development Workflow

### Before Committing

Pre-commit hooks run automatically on `git commit`. To run manually:

```bash
pre-commit run --all-files
```

### Running Checks Individually

```bash
# Format all Terraform files
terraform fmt -recursive

# Validate a specific module
cd modules/talos-cluster
terraform init -backend=false
terraform validate

# Run TFLint on a module
tflint --config "$PWD/.tflint.hcl" --chdir modules/talos-cluster

# Run security scan
trivy config --config trivy.yaml .

# Generate documentation
terraform-docs --config .terraform-docs.yml modules/talos-cluster
```

## Pull Request Process

1. Create a feature branch from `main`
2. Make your changes
3. Ensure all checks pass:
   - `terraform fmt` - Code formatting
   - `terraform validate` - Syntax validation
   - `tflint` - Linting rules
   - `trivy` - Security scanning
   - `terraform-docs` - Documentation is up-to-date
4. Update documentation if adding/changing variables or outputs
5. Submit a pull request

### Required Status Checks

All PRs must pass:
- Terraform validation for all 8 modules
- Security scan (Trivy)
- Code owner review (@jfreed-dev)

## Module Structure

Each module should contain:

```
modules/<name>/
├── main.tf           # Main resources
├── variables.tf      # Input variables (with descriptions)
├── outputs.tf        # Output values (with descriptions)
├── versions.tf       # Provider requirements
└── README.md         # Documentation with <!-- BEGIN_TF_DOCS --> markers
```

### Documentation

Module READMEs use terraform-docs for auto-generated sections. Add these markers where you want the generated content:

```markdown
<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
```

The sections above the markers (Usage examples, etc.) are manually maintained.

## Code Style

- Use `snake_case` for resource names, variables, and outputs
- Include descriptions for all variables and outputs
- Use `optional()` for optional object attributes with defaults
- Keep provider version constraints in `versions.tf`
- Avoid hardcoded values; use variables with sensible defaults

## Commit Messages

Follow conventional commit style:
- `feat:` New features
- `fix:` Bug fixes
- `docs:` Documentation changes
- `chore:` Maintenance tasks
- `refactor:` Code refactoring

## Questions?

Open an issue for questions or suggestions.
