# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability, please report it responsibly:

1. **Do not** open a public issue
2. Email the maintainer directly or use GitHub's private vulnerability reporting
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

## Security Best Practices

When using these Terraform modules:

- Never commit sensitive values (API keys, passwords) to version control
- Use Terraform variables and environment variables for secrets
- Enable state encryption for remote backends
- Review module changes before applying updates
- Use version pinning for production deployments

### Credential Management

1. **Use environment variables** for credentials instead of hardcoding in `.tf` files:

   ```bash
   export TURINGPI_USERNAME="root"
   export TURINGPI_PASSWORD="your-password"
   ```

2. **Never commit** `terraform.tfstate` files containing credentials to version control
   - Add `*.tfstate` and `*.tfstate.backup` to `.gitignore`
   - Use remote state backends with encryption (S3, GCS, Terraform Cloud)

3. **Use HTTPS** endpoints (the default) for BMC communication

4. **Enable TLS verification** (default) — only use
   `insecure = true` in development environments

5. **Test configurations** (`test/` directory) must use
   `sensitive` variables, not hardcoded passwords:

   ```hcl
   variable "bmc_password" {
     type      = string
     sensitive = true
   }
   ```

   Supply values via `terraform.tfvars` (gitignored)
   or `TF_VAR_*` environment variables

## Supply Chain Security

This repository implements security best practices:

- **Pinned Actions**: All GitHub Actions are pinned to SHA commits
- **Dependabot**: Automated security updates for Terraform providers and GitHub Actions
- **Signed Releases**: All releases are GPG-signed tags
- **Branch Protection**: Main branch requires review and passing CI
- **Security Scanning**: Trivy IaC scanning and dependency review on all PRs

## Response Timeline

- **Initial Response**: Within 48 hours
- **Status Update**: Within 7 days
- **Fix Release**: Depends on severity and complexity
