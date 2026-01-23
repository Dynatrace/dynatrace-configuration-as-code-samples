# AI Agent Instructions for Dynatrace Configuration-as-Code Samples

> **This is the single source of truth for all AI agent instructions in this repository.**
> All AI tools (GitHub Copilot, Cursor, Claude, Kiro, etc.) should reference this file.

## Repository Overview

This repository contains sample projects demonstrating Dynatrace Configuration as Code using both Terraform and Monaco (Dynatrace-specific CLI tool). The samples cover various use cases including:

- Pipeline observability (GitHub, GitLab, Azure DevOps, ArgoCD)
- Service Level Objectives (SLOs)
- IAM and access control management
- Dashboard creation and management
- Monitoring and alerting configurations
- GRAIL bucket management
- Segment management
- Workflow automation

## Environment Information

- **Dynatrace Environment**: Platform environments (Gen3) using apps.dynatrace.com
- **Authentication**: Platform token or OAuth-based authentication is REQUIRED for Platform environments
- **Primary Tools**: Terraform with Dynatrace provider v1.89+ (recommended), Monaco CLI v2.28.0+
- **Repository Owner**: Dynatrace organization

---

## Core Principles

### 1. Security First

- **NEVER hardcode credentials** - use environment variables exclusively
- **ALWAYS use OAuth authentication or platform tokens** for Dynatrace Platform environments (preferred over API tokens)
- **Token Compatibility**:
  - Classic API tokens can be used together with OAuth or platform tokens
  - Platform tokens and OAuth **cannot** be used together (mutually exclusive)
- **DO NOT use Terraform variables for tokens/credentials** (they get stored in state file - use environment variables or credential vaults)
- When creating new samples or modifying authentication:
  - Use `DYNATRACE_PLATFORM_TOKEN` or OAuth client credentials (`CLIENT_ID`, `CLIENT_SECRET`)
  - Document required OAuth scopes in README files
  - Create `.env.example` files with placeholder values (NEVER real credentials)
  - Use format: `export VAR_NAME="<PLACEHOLDER_DESCRIPTION>"` in shell scripts

### 2. Version Requirements (January 2026)

| Tool               | Minimum Version | Recommended Version | Notes                                    |
|--------------------|-----------------|---------------------|------------------------------------------|
| Monaco             | 2.24.0          | 2.28.0+             | Required for latest Platform features    |
| Terraform          | 1.0.0           | 1.14.0+             | Use latest stable                        |
| Dynatrace Provider | 1.85.0          | 1.89.0+             | Check registry for latest                |
| Dynatrace Platform | -               | Current             | Platform environments required for OAuth |

- Document version requirements in every README
- Check [Terraform Registry](https://registry.terraform.io/providers/dynatrace-oss/dynatrace/latest) for updates
- For detailed information, see [Dynatrace Configuration as Code](https://docs.dynatrace.com/docs/deliver/configuration-as-code)

### 3. Documentation Requirements

Every sample MUST have a README.md with:
- **Title**: Clear description of the use case
- **Use Case Overview**: Business value and technical implementation
- **Prerequisites**: Required Monaco/Terraform version, Dynatrace environment type
- **OAuth Scopes**: Complete list of required scopes (see template below)
- **Environment Variables**: Complete list with descriptions
- **Project/File Structure**: Overview of files and their purpose
- **Setup Instructions**: Step-by-step deployment guide
- **Images/Screenshots**: Expected outcome (where applicable)
- **Verification**: How to verify successful deployment
- **Cleanup Instructions**: How to delete/remove configurations
- **Troubleshooting**: Common issues and solutions
- **Links**: Use official Dynatrace documentation URLs

---

## Terraform Standards

### Provider Configuration

```hcl
terraform {
  required_version = ">= 1.0"

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
  # Provider automatically reads from environment variables:
  # - DYNATRACE_ENV_URL for dt_env_url
  # - DT_CLIENT_ID for client_id (OAuth, recommended for Platform)
  # - DT_CLIENT_SECRET for client_secret (OAuth, recommended for Platform)
  # - DT_ACCOUNT_ID for account_id (OAuth, recommended for Platform)
  # OR
  # - DYNATRACE_API_TOKEN for dt_api_token (legacy, for Classic environments)
  #
  # Do NOT use Terraform variables for credentials as they get stored in state file.
}
```

### Environment Variables for Authentication

**Required Environment Variables:**
```bash
# Environment URL (required)
export DYNATRACE_ENV_URL="https://abc12345.apps.dynatrace.com"

# OAuth credentials (recommended for Platform environments)
export DT_CLIENT_ID="your-client-id"
export DT_CLIENT_SECRET="your-client-secret"
export DT_ACCOUNT_ID="your-account-uuid"

# OR API Token (legacy, for Classic environments)
export DYNATRACE_API_TOKEN="your-api-token"
```

For production use, consider using credential vaults like HashiCorp Vault instead of plain environment variables.

### Dynamic Configuration Example

```hcl
locals {
  environments = {
    dev  = { retention = 7,  replicas = 1 }
    prod = { retention = 30, replicas = 3 }
  }

  env_config = local.environments[var.environment]
}

resource "dynatrace_segment" "this" {
  name        = "${var.environment}-segment"
  description = "Segment for ${var.environment} environment"

  includes {
    items {
      data_object = "logs"
      # ... configuration
    }
  }
}
```

---

## Monaco Standards

### Manifest File Structure

```yaml
manifestVersion: 1.0  # Current stable version is 1.0 (unquoted)
projects:
  - name: descriptive-project-name
    path: path/to/configs

environmentGroups:
  - name: group-name
    environments:
      - name: environment-name
        url:
          type: value
          value: https://<ENV-ID>.apps.dynatrace.com
        auth:
          platformToken:
            name: DYNATRACE_PLATFORM_TOKEN
          # Preferred: OAuth
          # oAuth:
          #   clientId:
          #     type: environment
          #     name: CLIENT_ID
          #   clientSecret:
          #     type: environment
          #     name: CLIENT_SECRET
```

### Configuration File Pattern

```yaml
configs:
  - id: unique-config-id
    config:
      name: "Configuration Name"
      template: config-template.json
      skip: false
    type:
      settings:
        schema: builtin:settings.schema.id
        scope: environment  # or entity scope
```

### Reference Between Configurations

```yaml
configs:
  - id: segment
    type: segment
    config:
      name: "Production Segment"
      template: segment-template.json

  - id: dashboard
    type:
      document:
        kind: dashboard
        private: true
    config:
      name: "Prod Dashboard"
      template: dashboard-template.json
      parameters:
        segment_id:
          type: reference
          configId: segment
          configType: segment
          property: id
```

### Environment-Specific Variables

```yaml
configs:
  - id: my-config
    config:
      name: "{{ .Env.ENVIRONMENT_NAME }}"
      template: config.json
    type:
      settings:
        schema: builtin:my.schema
        scope: environment
```

### Multi-Environment Deployments

```yaml
manifestVersion: 1.0
projects:
  - name: shared-config
    path: configs

environmentGroups:
  - name: development
    environments:
      - name: dev-env-1
        url:
          value: https://dev001.apps.dynatrace.com
        auth:
          oAuth:
            clientId:
              type: environment
              name: DEV_CLIENT_ID
            clientSecret:
              type: environment
              name: DEV_CLIENT_SECRET

  - name: production
    environments:
      - name: prod-env-1
        url:
          value: https://prod001.apps.dynatrace.com
        auth:
          oAuth:
            clientId:
              type: environment
              name: PROD_CLIENT_ID
            clientSecret:
              type: environment
              name: PROD_CLIENT_SECRET
```

---

## OAuth Scopes Reference

Document all required scopes in README files. Common scopes:

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

### OAuth Scope Documentation Template

```markdown
## OAuth Client Requirements

Create an OAuth client with the following scopes:

**Platform Access**:
- `settings:objects:read` - Read settings configurations
- `settings:objects:write` - Write settings configurations
- `settings:schemas:read` - Read settings schemas

**[Feature-Specific]**:
- `slo:slos:read`, `slo:slos:write` - SLO management
- `document:documents:read`, `document:documents:write` - Dashboard management

Create OAuth client: https://docs.dynatrace.com/docs/deliver/configuration-as-code/monaco/guides/create-oauth-client
```

---

## File Organization

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
├── locals.tf                    # Local values (optional)
├── scripts/
│   ├── deploy.sh               # Deployment script
│   └── cleanup.sh              # Cleanup script
└── images/                      # Screenshots/diagrams for README
```

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

### Standard .gitignore

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

---

## Environment Variable Management

**ALWAYS** use this pattern for credentials:

1. **Never hardcode** credentials in any file

2. **Create `.env.example`** with clear placeholders:
```bash
# .env.example
export DYNATRACE_ENV_URL="https://<YOUR-ENV-ID>.apps.dynatrace.com"
export CLIENT_ID="<YOUR-OAUTH-CLIENT-ID>"
export CLIENT_SECRET="<YOUR-OAUTH-CLIENT-SECRET>"
export DT_ACCOUNT_ID="<YOUR-ACCOUNT-UUID>"
```

3. **Add `.env` to `.gitignore`**

4. **Document in README**:
```markdown
## Setup

1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and fill in your actual values

3. Load environment variables:
   ```bash
   source .env
   ```
```

### Environment Variable Loading Script

```bash
#!/bin/bash
set -euo pipefail

# Validate required environment variables
required_vars=("DYNATRACE_ENV_URL" "CLIENT_ID" "CLIENT_SECRET")

for var in "${required_vars[@]}"; do
  if [ -z "${!var:-}" ]; then
    echo "Error: Required environment variable $var is not set"
    exit 1
  fi
done

echo "All required environment variables are set"
```

---

## Dynatrace-Specific Knowledge

### OpenPipeline Configuration

When working with OpenPipeline (logs/events/metrics ingestion):
- Always check existing configuration before modifying
- Use `monaco download` to get current state
- Merge new routes with existing ones (order matters!)
- Document the routing logic clearly
- Test with sample data before production deployment

### GRAIL Buckets

- Bucket names must be globally unique within the account
- Define retention policies carefully (cost implications)
- Use segments for fine-grained access control
- Document query patterns for each bucket

### SLO Configuration

- Use normalized SLI values (0-100% range)
- Define appropriate error budgets based on business needs
- Include burn rate alerts for proactive monitoring
- Use SLO templates for consistency across services

### IAM & Access Control

- Follow principle of least privilege
- Use policy boundaries to restrict access
- Group users by team/function
- Use environment-level policies for isolation
- Document policy inheritance chains

---

## Code Review Checklist

### Security
- [ ] No hardcoded credentials anywhere
- [ ] All secrets use environment variables
- [ ] `.env` is in `.gitignore`
- [ ] `.env.example` exists with placeholders
- [ ] Sensitive variables marked as `sensitive = true` in Terraform

### Version Compatibility
- [ ] Monaco version >= 2.24.0 or latest stable
- [ ] Terraform Dynatrace provider >= 1.89.0
- [ ] Terraform version >= 1.0.0
- [ ] Version requirements documented in README

### Authentication
- [ ] OAuth preferred over API tokens for Platform environments
- [ ] All required OAuth scopes documented
- [ ] OAuth client creation steps in README
- [ ] Authentication pattern consistent within sample

### Configuration Quality
- [ ] Manifest version is `1.0` (unquoted)
- [ ] Configuration IDs are descriptive and unique
- [ ] No hardcoded entity IDs (use references)
- [ ] Templates use variables appropriately
- [ ] Dependencies properly defined

### Documentation
- [ ] README.md follows standard template
- [ ] Prerequisites clearly listed
- [ ] Step-by-step setup instructions
- [ ] Cleanup/deletion instructions included
- [ ] OAuth scopes documented
- [ ] Example outputs or screenshots provided
- [ ] Troubleshooting section present

### Testing
- [ ] Deployment steps are testable
- [ ] Dry-run/plan command documented
- [ ] Validation steps included
- [ ] Cleanup verified to work

---

## Common Mistakes to Avoid

1. Using outdated Terraform provider versions (< 1.85)
2. Mixing API token and OAuth in the same sample
3. Hardcoding entity IDs instead of using references
4. Omitting OAuth scope documentation
5. Not providing cleanup/deletion instructions
6. Creating samples without `.env.example` files
7. Using API v1 endpoints when v2 exists
8. Not validating configurations before deployment
9. Ignoring Monaco/Terraform version requirements
10. Missing error handling in shell scripts
11. Using Terraform variables for tokens/credentials
12. Using platform token and OAuth together (mutually exclusive)

---

## Commands Reference

### Terraform

```bash
terraform init              # Initialize
terraform validate          # Validate
terraform fmt -recursive    # Format
terraform plan              # Plan changes
terraform apply             # Apply changes
terraform destroy           # Destroy resources
terraform state list        # List resources
terraform state show        # Show resource
```

### Monaco

```bash
monaco deploy manifest.yaml              # Deploy
monaco deploy --dry-run manifest.yaml    # Validate (dry run)
monaco delete -m manifest.yaml           # Delete
monaco download -e ENV_ID                # Download existing config
monaco convert --source v1/ --target v2/ # Convert v1 to v2
```

### Environment

```bash
source .env                # Load environment variables
printenv | grep DT         # Check Dynatrace variables
```

---

## Validation Steps

Before finalizing any changes:

```bash
# Monaco validation
monaco deploy manifest.yaml --dry-run

# Terraform validation
terraform init
terraform validate
terraform fmt -check -recursive
terraform plan

# Security scan (if available)
git secrets --scan

# Documentation check
# - README.md exists and follows template
# - All OAuth scopes documented
# - .env.example exists
# - Cleanup instructions present
```

---

## AI Agent Guidelines

When generating or modifying code:

1. **Check version compatibility** - Always use latest stable versions
2. **Validate OAuth scopes** - Ensure all required scopes are documented
3. **Security first** - Never expose credentials, always use env vars
4. **Follow existing patterns** - Maintain consistency with other samples
5. **Test instructions** - Verify deployment steps are accurate
6. **Update documentation** - Keep README files synchronized with code changes
7. **Ask clarifying questions** if requirements are unclear
8. **Include complete documentation** - Never just code, always include README
9. **Provide examples** - Include sample `.env.example` and shell scripts

When reviewing existing code:

1. **Check against standards** - Use the checklist above
2. **Identify security issues** - Flag any credential exposure
3. **Suggest modernizations** - Propose updates to latest versions/APIs
4. **Be specific** - Provide exact line numbers and code snippets for changes
5. **Explain why** - Always explain the reasoning behind suggestions

When troubleshooting:

1. **Check versions** - Verify Monaco/Terraform versions are compatible
2. **Validate credentials** - Ensure OAuth scopes are sufficient
3. **Review logs** - Look for specific error messages
4. **Provide workarounds** - Offer alternatives if issues can't be immediately resolved
5. **Document solutions** - Add to troubleshooting sections

---

## References

- [Dynatrace Configuration as Code Documentation](https://docs.dynatrace.com/docs/shortlink/configuration-as-code)
- [Terraform Provider Documentation](https://registry.terraform.io/providers/dynatrace-oss/dynatrace/latest/docs)
- [Dynatrace API Documentation](https://docs.dynatrace.com/docs/dynatrace-api)
- [Authentication Guide](https://docs.dynatrace.com/docs/shortlink/terraform-api-support-access-permission-handling)
- [Settings Schema Browser](https://docs.dynatrace.com/docs/dynatrace-api/environment-api/settings)
- [Create OAuth Client](https://docs.dynatrace.com/docs/deliver/configuration-as-code/monaco/guides/create-oauth-client)
- [Platform Tokens](https://docs.dynatrace.com/docs/shortlink/platform-tokens)

---

**Last Updated**: January 2026
**Maintainers**: Dynatrace Configuration-as-Code Team
**Repository**: github.com/Dynatrace/dynatrace-configuration-as-code-samples
