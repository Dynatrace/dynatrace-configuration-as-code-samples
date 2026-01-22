# GitHub Copilot Instructions for Dynatrace Configuration-as-Code Samples

## Repository Context

This repository contains sample projects demonstrating Dynatrace Configuration as Code using both Terraform and Monaco (Dynatrace-specific CLI tool). The samples cover various use cases, including monitoring, observability, IAM, SLOs, dashboards, and pipeline observability.

## Core Principles

### 1. Authentication & Security
- **ALWAYS use OAuth authentication or platform tokens** for Dynatrace Platform environments (preferred over API tokens)
- **NEVER hardcode credentials** - use environment variables exclusively
- **Token Compatibility**:
  - Classic API tokens can be used together with OAuth or platform tokens
  - Platform tokens and OAuth **cannot** be used together (mutually exclusive)
- When creating new samples or modifying authentication:
  - Use `DYNATRACE_PLATFORM_TOKEN` or OAuth client credentials (`CLIENT_ID`, `CLIENT_SECRET`)
  - Document required OAuth scopes in README files
  - Create `.env.example` files with placeholder values (NEVER real credentials)
  - Use format: `export VAR_NAME="<PLACEHOLDER_DESCRIPTION>"` in shell scripts

### 2. Terraform Best Practices
- **Provider Version**: Always use the latest stable Dynatrace provider version
  - As of January 2026: `version = "~> 1.89"` or higher
  - Check [Terraform Registry](https://registry.terraform.io/providers/dynatrace-oss/dynatrace/latest) for updates
- **Provider Configuration**:
  ```hcl
  terraform {
    required_providers {
      dynatrace = {
        version = "~> 1.89"
        source  = "dynatrace-oss/dynatrace"
      }
    }
    
    backend "local" {
    path = "./terraform.tfstate"
  }
  }

  provider "dynatrace" {
    dt_env_url    = var.DYNATRACE_ENV_URL    # from DYNATRACE_ENV_URL env var
    dt_api_token  = var.DYNATRACE_API_TOKEN  # from DYNATRACE_API_TOKEN env var
    # OR use OAuth (recommended):
    # client_id     = var.DT_CLIENT_ID
    # client_secret = var.DT_CLIENT_SECRET
    # account_id    = var.DT_ACCOUNT_ID
  }
  ```

### 3. Monaco Best Practices
- **Monaco version**: Always use the latest stable version: Use Monaco v2.28.0 or later for new samples
- **Manifest Version**: Always use `manifestVersion: 1.0` (unquoted)
- **Project Structure**:
  ```yaml
  manifestVersion: 1.0
  projects:
    - name: <descriptive-project-name>
      path: <project-path>
  environmentGroups:
    - name: <group-name>
      environments:
        - name: <env-name>
          url:
            type: value
            value: https://<YOUR-ENV-ID>.apps.dynatrace.com
          auth:
            platformToken:
              name: DYNATRACE_PLATFORM_TOKEN
  ```
- **OAuth Configuration** (preferred):
  ```yaml
  auth:
    oAuth:
      clientId:
        type: environment
        name: CLIENT_ID
      clientSecret:
        type: environment
        name: CLIENT_SECRET
  ```

### 4. Documentation Standards
Every sample MUST include a README.md with:
- **Title**: Clear description of the use case
- **Prerequisites**:
  - Required Terraform/Monaco version
  - Dynatrace environment type (Platform/Classic)
  - Required OAuth scopes or API token permissions (listed explicitly)
- **Environment Variables**: Complete list with descriptions
- **Setup Instructions**: Step-by-step deployment guide
- **Screenshots / Images** of the expected outcome, where applicable
- **Cleanup Instructions**: How to delete/remove configurations
- **Links**: Use official Dynatrace documentation URLs (https://docs.dynatrace.com)

### 5. File Naming & Organization
- Use lowercase with hyphens for directories: `pipeline-observability`, `service-level-objectives`
- Configuration files: Use descriptive names like `main.tf`, `provider.tf, `variables.tf`, `output.tf`, `locals.tf`, `config.yaml`, `manifest.yaml`, `<resources>.tf`, etc.
- Scripts: Use `.sh` extension with descriptive names: `deploy.sh`, `cleanup.sh`, `configure.sh`
- Make scripts executable: `chmod +x script.sh`

### 6. Version Control & Gitignore
Standard `.gitignore` entries for each sample directory:
```gitignore
.env
*.env
!.env.example
*.tfstate
*.tfstate.*
.terraform/
.terraform.lock.hcl
download_*/
converted-v2-config/
*.bak
.logs/
request.log
response.log
```

### 7. OAuth Scopes Reference
Common scopes for different use cases:

- Note: The required scopes vary depending on the use case and required resources.


**Basic Configuration Management**:
- `settings:objects:read`, `settings:objects:write`
- `settings:schemas:read`
- `ReadConfig`, `WriteConfig` (API v1)

**SLOs**:
- `slo:slos:read`, `slo:slos:write`

**Documents & Dashboards**:
- `document:documents:read`, `document:documents:write`

**OpenPipeline**:
- `openpipeline:configurations:read`, `openpipeline:configurations:write`

**Grail Buckets**:
- `storage:bucket-definitions:read`, `storage:bucket-definitions:write`
- `storage:filter-segments:read`, `storage:filter-segments:write`

**IAM & Account Management**:
- `account-idm-read`, `account-idm-write`
- `iam:groups:read`, `iam:groups:write`
- `iam-policies-management`

**Workflows & Automation**:
- `automation:workflows:read`, `automation:workflows:write`, `automation:workflows:run`
- `app-engine:apps:run`, `app-engine:apps:install`

### 8. Error Handling & Validation
- Include validation steps in README files
- Provide troubleshooting sections for common issues
- Use Monaco's `--dry-run` flag for validation before deployment
- For Terraform: Always run `terraform plan` before `terraform apply`

### 9. Dependencies & Configuration References
- Use Monaco's dependency management for related configurations
- Document configuration interdependencies in README
- Use meaningful configuration names and IDs
- Avoid hardcoded entity IDs; use references instead

### 10. Multi-Environment Support
- Use environment groups in Monaco manifests
- Use Terraform workspaces for multiple environments
- Document environment-specific variables clearly
- Provide examples for dev/staging/production patterns

## Code Generation Guidelines

When generating or modifying code:
1. **Check version compatibility** - Always use latest stable versions
2. **Validate OAuth scopes** - Ensure all required scopes are documented
3. **Security first** - Never expose credentials, always use env vars
4. **Follow existing patterns** - Maintain consistency with other samples
5. **Test instructions** - Verify deployment steps are accurate
6. **Update documentation** - Keep README files synchronized with code changes

## Common Patterns

### Environment Variable Loading (Shell)
```bash
#!/bin/bash
# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "Error: .env file not found"
    exit 1
fi
```

### Monaco Deployment Script
```bash
#!/bin/bash
set -e
echo "Deploying Dynatrace configuration..."
monaco deploy manifest.yaml
echo "Deployment completed successfully!"
```

### Terraform Variables Pattern
```hcl
variable "DYNATRACE_ENV_URL" {
  description = "Dynatrace environment URL (e.g., https://abc12345.apps.dynatrace.com)"
  type        = string
  sensitive   = false
}

variable "DYNATRACE_API_TOKEN" {
  description = "Dynatrace API token or Platform token"
  type        = string
  sensitive   = true
}
```

## Critical Don'ts
- ❌ Don't use outdated Terraform provider versions (< 1.85)
- ❌ Don't hardcode environment URLs or credentials
- ❌ Don't omit OAuth scope documentation
- ❌ Don't create samples without cleanup instructions
- ❌ Don't use platform token and OAuth together (they are mutually exclusive)
- ❌ Don't reference deprecated API endpoints
- ❌ Don't forget to update README when changing configurations

## Useful Commands Reference

### Monaco
```bash
# Deploy configuration
monaco deploy manifest.yaml

# Delete configuration
monaco delete -m manifest.yaml

# Download existing configuration
monaco download -e <ENV-ID> --settings-schema "schema-id"

# Validate configuration
monaco deploy manifest.yaml --dry-run

# Convert v1 to v2
monaco convert --source v1-config/ --target v2-config/
```

### Terraform
```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy resources
terraform destroy

# Format code
terraform fmt -recursive
```

## Sample Directory Template Structure

### Monaco Sample Structure
```
monaco-sample-name/
├── README.md                    # Comprehensive documentation
├── manifest.yaml                # Monaco manifest
├── delete.yaml                  # Monaco delete configuration (if applicable)
├── .gitignore                   # Git ignore file
├── .env.example                 # Example environment variables
├── scripts/
│   ├── deploy.sh               # Deployment script
│   └── cleanup.sh              # Cleanup script
├── config/                      # Configuration files
│   └── *.yaml                  # Monaco config files
└── images/                      # Screenshots/diagrams for README
```

### Terraform Sample Structure
```
terraform-sample-name/
├── README.md                    # Comprehensive documentation
├── .gitignore                   # Git ignore file
├── .env.example                 # Example environment variables
├── providers.tf                 # Terraform providers
├── variables.tf                 # Terraform variables
├── main.tf                      # Terraform main config
├── outputs.tf                   # Terraform outputs (optional)
├── scripts/
│   ├── deploy.sh               # Deployment script
│   └── cleanup.sh              # Cleanup script
└── images/                      # Screenshots/diagrams for README
```

## Version Compatibility Matrix (January 2026)

| Tool              | Minimum Version | Recommended Version | Notes                                    |
|-------------------|----------------|---------------------|------------------------------------------|
| Monaco            | 2.22.0         | 2.28.0+             | Required for latest Platform features    |
| Terraform         | 1.0.0          | 1.6.0+              | Use latest stable                        |
| Dynatrace Provider| 1.85.0         | 1.89.0+             | Check registry for latest                |
| Dynatrace Platform| -              | Current             | Platform environments required for OAuth |

## References
- [Dynatrace Configuration as Code Documentation](https://docs.dynatrace.com/docs/deliver/configuration-as-code)
- [Monaco Documentation](https://docs.dynatrace.com/docs/deliver/configuration-as-code/monaco)
- [Terraform Provider Documentation](https://registry.terraform.io/providers/dynatrace-oss/dynatrace/latest/docs)
- [Dynatrace API Documentation](https://docs.dynatrace.com/docs/dynatrace-api)
- [Authentication Guide](https://docs.dynatrace.com/docs/shortlink/terraform-api-support-access-permission-handling)

---
Last Updated: January 2026
Maintainers: Dynatrace Configuration-as-Code Team
