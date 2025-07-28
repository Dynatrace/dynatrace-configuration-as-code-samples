# Problem Notification with Auto-Tagging

> **Automated incident response using auto-tagging and targeted notifications**

This example demonstrates how to set up intelligent problem notifications based on auto-tagging rules. It solves the common challenge of ensuring that Dynatrace problems reach the responsible teams quickly and efficiently.

> **💡 Note**: This example uses auto-tagging for team assignment. While auto-tagging is a current Dynatrace capability, it may evolve as Dynatrace introduces new data organization and filtering capabilities.

## 🎯 What You'll Get

### 🚨 **Intelligent Alert Routing**
- **Auto-tagging rules** for automatic team assignment
- **Targeted notifications** based on ownership
- **Multiple notification channels** (Email, Slack)
- **Reduced alert fatigue** through smart filtering

### 🔄 **Automated Team Assignment**
- **Host group-based** tagging for infrastructure teams
- **Kubernetes namespace** tagging for application teams
- **AWS project** tagging for cloud teams
- **Database and service** tagging for specialized teams

## 📋 Prerequisites

- **Dynatrace Environment**: Active Dynatrace SaaS or Managed environment
- **Monaco CLI**: [Download here](https://github.com/Dynatrace/dynatrace-configuration-as-code/releases)
- **Notification Channels**: Email server or Slack workspace
- **Permissions**: API token with settings and data export permissions

### Required Permissions
```
API Token Scopes:
- settings.read
- settings.write
- Data Export
```

## 🛠️ Quick Start

### 1. Configure Environment Variables
```bash
# Set your environment variables
export DEMO_ENV_URL="https://your-environment.apps.dynatrace.com"
export DEMO_ENV_TOKEN="your-api-token"
```

### 2. Choose Your Auto-Tagging Strategy
```yaml
# Edit sample/auto-tag/config.yaml to select your strategy:

# Option 1: Host group-based (default)
host_group_tagging:
  enabled: true
  host_group: "production-hosts"
  team_tag: "team=infrastructure"

# Option 2: Kubernetes namespace-based
kubernetes_tagging:
  enabled: false  # Set to true to use
  namespace: "production"
  team_tag: "team=application"

# Option 3: AWS project-based
aws_tagging:
  enabled: false  # Set to true to use
  project: "main-project"
  team_tag: "team=cloud"
```

### 3. Deploy Configuration
```bash
# Deploy the problem notification setup
monaco deploy manifest.yaml
```

**Time to value: 25 minutes** ⚡

## 📁 Configuration Structure

```
problem_notification_sample/
├── manifest.yaml                    # Monaco manifest
├── delete.yaml                      # Cleanup configuration
├── sample/
│   ├── alerting-profile/
│   │   ├── config.yaml             # Alerting profile configuration
│   │   └── template.json           # Alerting profile template
│   ├── auto-tag/
│   │   ├── config.yaml             # Auto-tagging configuration
│   │   ├── aws_k8s_template.json   # AWS/K8s tagging template
│   │   ├── host_template.json      # Host-based tagging template
│   │   └── k8s_template.json       # K8s namespace tagging template
│   └── notification/
│       ├── config.yaml             # Notification configuration
│       ├── email_template.json     # Email notification template
│       └── slack_template.json     # Slack notification template
└── README.md
```

## 🎛️ Auto-Tagging Strategies

### 1. **Host Group-Based Tagging** (Default)
```json
{
  "name": "Infrastructure Team Tagging",
  "description": "Tag hosts in production host group",
  "rules": [
    {
      "type": "HOST",
      "enabled": true,
      "propagationTypes": ["HOST_TO_PROCESS_GROUP_INSTANCE"],
      "conditions": [
        {
          "key": {
            "attribute": "HOST_GROUP_NAME"
          },
          "comparisonInfo": {
            "type": "STRING",
            "operator": "EQUALS",
            "value": "production-hosts",
            "negate": false
          }
        }
      ],
      "valueFormat": "team=infrastructure"
    }
  ]
}
```

### 2. **Kubernetes Namespace Tagging**
```json
{
  "name": "Application Team Tagging",
  "description": "Tag services in production namespace",
  "rules": [
    {
      "type": "SERVICE",
      "enabled": true,
      "propagationTypes": ["SERVICE_TO_HOST_LIKE"],
      "conditions": [
        {
          "key": {
            "attribute": "KUBERNETES_NAMESPACE"
          },
          "comparisonInfo": {
            "type": "STRING",
            "operator": "EQUALS",
            "value": "production",
            "negate": false
          }
        }
      ],
      "valueFormat": "team=application"
    }
  ]
}
```

### 3. **AWS Project Tagging**
```json
{
  "name": "Cloud Team Tagging",
  "description": "Tag AWS resources in main project",
  "rules": [
    {
      "type": "SERVICE",
      "enabled": true,
      "propagationTypes": ["SERVICE_TO_HOST_LIKE"],
      "conditions": [
        {
          "key": {
            "attribute": "AWS_ACCOUNT_ID"
          },
          "comparisonInfo": {
            "type": "STRING",
            "operator": "EQUALS",
            "value": "123456789012",
            "negate": false
          }
        }
      ],
      "valueFormat": "team=cloud"
    }
  ]
}
```

## 🔧 Notification Configuration

### Email Notifications
```json
{
  "name": "Team Email Notifications",
  "description": "Email notifications for team-owned problems",
  "type": "EMAIL",
  "email": {
    "recipients": ["team@company.com"],
    "subject": "Dynatrace Problem Alert: {{ProblemTitle}}",
    "body": "Problem detected for {{EntityName}} owned by {{Team}}"
  },
  "filter": {
    "tagFilter": {
      "includeMode": "INCLUDE_ALL",
      "tagFilters": [
        {
          "context": "CONTEXTLESS",
          "key": "team",
          "value": "infrastructure"
        }
      ]
    }
  }
}
```

### Slack Notifications
```json
{
  "name": "Team Slack Notifications",
  "description": "Slack notifications for team-owned problems",
  "type": "SLACK",
  "slack": {
    "channel": "#team-alerts",
    "message": "🚨 Problem detected: {{ProblemTitle}} for {{EntityName}}"
  },
  "filter": {
    "tagFilter": {
      "includeMode": "INCLUDE_ALL",
      "tagFilters": [
        {
          "context": "CONTEXTLESS",
          "key": "team",
          "value": "application"
        }
      ]
    }
  }
}
```

## 🚨 Alerting Profile Configuration

### Team-Specific Alerting
```json
{
  "name": "Infrastructure Team Alerts",
  "description": "Alerting profile for infrastructure team",
  "severityRules": [
    {
      "severityLevel": "AVAILABILITY",
      "delayInMinutes": 5,
      "userDefined": false
    },
    {
      "severityLevel": "ERROR",
      "delayInMinutes": 2,
      "userDefined": false
    },
    {
      "severityLevel": "PERFORMANCE",
      "delayInMinutes": 10,
      "userDefined": false
    },
    {
      "severityLevel": "RESOURCE_CONTENTION",
      "delayInMinutes": 15,
      "userDefined": false
    }
  ],
  "tagFilter": {
    "includeMode": "INCLUDE_ALL",
    "tagFilters": [
      {
        "context": "CONTEXTLESS",
        "key": "team",
        "value": "infrastructure"
      }
    ]
  }
}
```

## 🔧 Customization Options

### Team Configurations
```yaml
# Team-specific configurations
teams:
  infrastructure:
    tag: "team=infrastructure"
    email: "infra@company.com"
    slack: "#infrastructure-alerts"
    delay_minutes: 5
  
  application:
    tag: "team=application"
    email: "app@company.com"
    slack: "#application-alerts"
    delay_minutes: 2
  
  cloud:
    tag: "team=cloud"
    email: "cloud@company.com"
    slack: "#cloud-alerts"
    delay_minutes: 3
```

### Notification Channels
- **Email**: Traditional email notifications
- **Slack**: Real-time team collaboration
- **Microsoft Teams**: Enterprise team communication
- **PagerDuty**: On-call escalation
- **Webhook**: Custom integrations

## 🔍 Troubleshooting

### Common Issues

**1. Auto-Tagging Not Working**
```bash
# Check entity attributes
# Verify tag propagation
# Test with simple conditions
```

**2. Notifications Not Sending**
```bash
# Verify notification configuration
# Check channel credentials
# Test notification delivery
```

**3. Alerting Profile Issues**
```bash
# Check tag filter syntax
# Verify severity rules
# Test alerting logic
```

### Debug Commands
```bash
# Validate configuration
monaco validate manifest.yaml

# Dry run deployment
monaco deploy manifest.yaml --dry-run

# Check auto-tagging status
# Navigate to Settings > Tags > Automatically applied tags
```

## 🏆 Best Practices

### 1. **Auto-Tagging Strategy**
- Use consistent naming conventions
- Start with simple, reliable criteria
- Test tagging rules thoroughly
- Regular review and cleanup

### 2. **Notification Management**
- Set appropriate delays for different severities
- Use team-specific channels
- Include relevant context in messages
- Regular notification testing

### 3. **Team Organization**
- Align tagging with organizational structure
- Document team responsibilities
- Regular team assignment reviews
- Escalation procedures for unassigned problems

### 4. **Monitoring & Optimization**
- Track notification delivery rates
- Monitor response times
- Regular alert fatigue assessment
- Continuous improvement process

## 🤝 Community Support

- **Questions?** [Open an issue](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples/issues)
- **Improvements?** [Contribute](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples/pulls)

## 📚 Additional Resources

- **[Auto-Tagging Documentation](https://docs.dynatrace.com/docs/shortlink/auto-tagging)**
- **[Problem Notification Guide](https://docs.dynatrace.com/docs/shortlink/problem-notifications)**
- **[Alerting Profile Best Practices](https://docs.dynatrace.com/docs/shortlink/alerting-profiles)**
- **[Monaco Configuration Guide](https://docs.dynatrace.com/docs/shortlink/monaco)**

---

**Ready to automate your incident response?** Start with the quick setup above! 🚀