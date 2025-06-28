# Dynatrace Template Hub

> **Comprehensive collection of Monaco v2 templates for every Dynatrace configuration and setting**

This template hub provides ready-to-use Monaco v2 templates for all Dynatrace configurations and settings. It serves as a reference library for building custom configurations and learning Monaco v2 syntax.

> **💡 Note**: These templates demonstrate current Dynatrace capabilities. Some features like auto-tagging and management zones may evolve as Dynatrace introduces new data organization and filtering capabilities.

## 🎯 What You'll Get

### 📚 **Template Library**
- **Complete coverage** of all Dynatrace configurations
- **Ready-to-use templates** with proper syntax
- **Configuration examples** for common use cases
- **Reference documentation** for Monaco v2

### 🔧 **Configuration Types**
- **Global configurations** (tags, management zones, alerting profiles)
- **Local settings** (services, monitors, applications)
- **Anomaly detection** (services, databases, Kubernetes, RUM)
- **Custom configurations** for specialized use cases

## 📋 Prerequisites

### 1. **Install Monaco**
```bash
# Download and install Monaco v2+
# Follow the installation guide:
https://www.dynatrace.com/support/help/shortlink/configuration-as-code-installation
```

### 2. **Create API Token**
```bash
# Required API v2 scopes:
- Read entities
- Write entities
- Read settings
- Write settings
- Read SLO
- Write SLO

# Required API v1 scopes:
- Read configuration
- Write configuration
- Access problem and event feed, metrics, and topology
```

### 3. **Set Environment Variables**
```bash
export API_TOKEN="your-api-token"
```

### 4. **Configure _manifest.yaml**
```yaml
environmentGroups:
- name: default
  environments:
  - name: ENV_NAME
    url:
      value: https://ENV_ID.live.dynatrace.com
    auth:
      token:
        name: API_TOKEN
```

## 🛠️ Quick Start

### 1. **Choose Your Template**
```bash
# Browse available templates by category
ls dynatrace_template_hub/

# Examples:
# - global/          # Global configurations
# - anomalyDetection/ # Anomaly detection settings
# - service/         # Service-specific settings
```

### 2. **Customize Configuration**
```yaml
# Edit the config.yaml file in your chosen template
# Example: anomalyDetection/serviceAnom/config.yaml
resp:
  enabled: true
  mode: "auto"
  degMilli: 399
  degPercent: 10
  reqPerMin: 15
  abState: 1
  sens: "low"
```

### 3. **Deploy Template**
```bash
# Deploy specific template
monaco deploy _manifest.yaml --project serviceAnom -e ENV_NAME

# Deploy multiple templates
monaco deploy _manifest.yaml --project "serviceAnom,kubernetesAnom" -e ENV_NAME
```

**Time to value: 10 minutes** ⚡

## 📁 Template Structure

```
dynatrace_template_hub/
├── _manifest.yaml                   # Monaco manifest
├── global/                          # Global configurations
│   ├── alertingProfile/            # Alerting profiles
│   ├── managementZone/             # Management zones
│   ├── ownership/                  # Ownership teams
│   └── tag/                        # Auto-tagging rules
├── anomalyDetection/               # Anomaly detection settings
│   ├── databaseServiceAnom/       # Database anomaly detection
│   ├── kubernetesAnom/            # Kubernetes anomaly detection
│   ├── rumAnom/                   # RUM anomaly detection
│   └── serviceAnom/               # Service anomaly detection
├── service/                        # Service-specific settings
│   ├── anomalyDetection/          # Service anomaly detection
│   ├── generalFailureDetection/   # General failure detection
│   ├── httpFailureDetection/      # HTTP failure detection
│   ├── keyRequests/               # Key requests
│   └── mutedRequests/             # Muted requests
├── browserMonitor/                 # Browser monitor settings
├── httpMonitor/                    # HTTP monitor settings
└── README.md
```

## 🎛️ Template Categories

### 🌐 **Global Configurations**
> Templates that can only be applied globally

| Template | Description | Command |
|----------|-------------|---------|
| **tag** | Auto-tagging rules | `monaco deploy _manifest.yaml --project tag -e ENV_NAME` |
| **managementZone** | Management zones | `monaco deploy _manifest.yaml --project managementZone -e ENV_NAME` |
| **ownership** | Ownership teams | `monaco deploy _manifest.yaml --project ownership -e ENV_NAME` |
| **alertingProfile** | Alerting profiles | `monaco deploy _manifest.yaml --project alertingProfile -e ENV_NAME` |

### 🔧 **Local Settings**
> Templates that can be applied locally

| Template | Description | Command |
|----------|-------------|---------|
| **service** | Service settings | `monaco deploy _manifest.yaml --project service -e ENV_NAME` |
| **browserMonitor** | Browser monitor settings | `monaco deploy _manifest.yaml --project browserMonitor -e ENV_NAME` |
| **httpMonitor** | HTTP monitor settings | `monaco deploy _manifest.yaml --project httpMonitor -e ENV_NAME` |

### 📊 **Anomaly Detection**
> Templates for anomaly detection settings

| Template | Description | Command |
|----------|-------------|---------|
| **databaseServiceAnom** | Database anomaly detection | `monaco deploy _manifest.yaml --project databaseServiceAnom -e ENV_NAME` |
| **serviceAnom** | Service anomaly detection | `monaco deploy _manifest.yaml --project serviceAnom -e ENV_NAME` |
| **kubernetesAnom** | Kubernetes anomaly detection | `monaco deploy _manifest.yaml --project kubernetesAnom -e ENV_NAME` |
| **rumAnom** | RUM anomaly detection | `monaco deploy _manifest.yaml --project rumAnom -e ENV_NAME` |

## 🔧 Configuration Examples

### Service Anomaly Detection
```yaml
# anomalyDetection/serviceAnom/config.yaml
configs:
  - id: globalServiceAnomalyDetection
    type:
      settings:
        schema: builtin:anomaly-detection.services
        scope: environment
    config:
      name: globalServiceAnomalyDetection
      template: object.json
      parameters:
        resp:
          type: value
          value:
            enabled: true
            mode: "auto"
            degMilli: 399
            degPercent: 10
            degSlowestMilli: 1000
            degSlowestPercent: 100
            reqPerMin: 15
            abState: 1
            sens: "low"
```

### Auto-Tagging Rule
```yaml
# global/tag/config.yaml
configs:
  - id: environment-tagging
    type:
      settings:
        schema: builtin:tags.auto-tagging
        scope: environment
    config:
      name: "Environment Tagging"
      template: object.json
      parameters:
        rules:
          type: value
          value:
            - name: "Environment Tagging"
              type: "SERVICE"
              enabled: true
              conditions:
                - attribute: "SERVICE_NAME"
                  operator: "CONTAINS"
                  value: "production"
              valueFormat: "environment=production"
```

### Management Zone
```yaml
# global/managementZone/config.yaml
configs:
  - id: production-zone
    type:
      settings:
        schema: builtin:management-zones
        scope: environment
    config:
      name: "Production Zone"
      template: object.json
      parameters:
        zones:
          type: value
          value:
            - name: "Production Zone"
              description: "Production environment"
              rules:
                - type: "SERVICE"
                  conditions:
                    - attribute: "SERVICE_TAG"
                      operator: "EQUALS"
                      value: "environment=production"
```

## 🔗 **Dependent Configurations**

### Workflow for Multiple Configurations
Some configurations depend on others. Here's how to handle dependencies:

#### 1. **Create Project Folder**
```bash
# Create a new project folder
mkdir my-project
cp -r global/managementZone my-project/
cp -r global/alertingProfile my-project/
```

#### 2. **Update _manifest.yaml**
```yaml
projects:
- name: my-project
  type: grouping
  path: my-project/
```

#### 3. **Configure Dependencies**
```yaml
# my-project/alertingProfile/config.yaml
configs:
  - id: production-alerts
    type:
      settings:
        schema: builtin:alerting.profile
        scope: environment
    config:
      name: "Production Alerting Profile"
      template: object.json
      parameters:
        managementZone:
          type: reference
          project: managementZone
          configType: builtin:management-zones
          configId: production-zone
          property: id
```

#### 4. **Deploy Together**
```bash
monaco deploy _manifest.yaml --project my-project -e ENV_NAME
```

## 🎯 **Common Use Cases**

### 1. **Service Monitoring Setup**
```bash
# Deploy service anomaly detection
monaco deploy _manifest.yaml --project serviceAnom -e ENV_NAME

# Deploy service settings
monaco deploy _manifest.yaml --project service -e ENV_NAME
```

### 2. **Kubernetes Monitoring**
```bash
# Deploy Kubernetes anomaly detection
monaco deploy _manifest.yaml --project kubernetesAnom -e ENV_NAME
```

### 3. **Web Application Monitoring**
```bash
# Deploy RUM anomaly detection
monaco deploy _manifest.yaml --project rumAnom -e ENV_NAME

# Deploy browser monitoring
monaco deploy _manifest.yaml --project browserMonitor -e ENV_NAME
```

## 🔍 **Troubleshooting**

### Common Issues

**1. Template Not Found**
```bash
# Check template path
ls dynatrace_template_hub/

# Verify project name in _manifest.yaml
```

**2. Configuration Errors**
```bash
# Validate configuration
monaco validate _manifest.yaml

# Check syntax in config.yaml files
```

**3. Permission Errors**
```bash
# Verify API token permissions
# Check OAuth client scopes
# Ensure environment access
```

### Debug Commands
```bash
# Dry run deployment
monaco deploy _manifest.yaml --project TEMPLATE_NAME -e ENV_NAME --dry-run

# Validate specific project
monaco validate _manifest.yaml --project TEMPLATE_NAME

# Check configuration status
# Navigate to Dynatrace UI to verify deployment
```

## 🏆 **Best Practices**

### 1. **Template Usage**
- Start with simple templates and expand
- Test configurations in non-production first
- Use descriptive names for custom configurations
- Document customizations and dependencies

### 2. **Configuration Management**
- Version control all customizations
- Use consistent naming conventions
- Regular review and cleanup of configurations
- Backup configurations before major changes

### 3. **Deployment Strategy**
- Deploy related configurations together
- Test dependencies before production deployment
- Use dry-run to validate changes
- Monitor deployment success rates

## 🤝 **Community Support**

- **Questions?** [Open an issue](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples/issues)
- **Improvements?** [Contribute](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples/pulls)

## 📚 **Additional Resources**

- **[Monaco v2 Documentation](https://docs.dynatrace.com/docs/shortlink/monaco)**
- **[Dynatrace Configuration API](https://docs.dynatrace.com/docs/shortlink/configuration-api)**
- **[Settings API Documentation](https://docs.dynatrace.com/docs/shortlink/settings-api)**

---

**Ready to build your configurations?** Start with the quick setup above! 🚀

> **Disclaimer**: This template hub is not officially supported by Dynatrace. Please use GitHub issues for any problems that arise. We will try our best to address your issues.
