# Grail Buckets Configuration

> **Configure custom Grail buckets and log routing rules using Monaco**

This example demonstrates how to create and manage [custom Grail buckets](https://www.dynatrace.com/support/help/platform/grail/data-model#custom-grail-buckets) using Monaco. Grail buckets allow you to organize and route specific logs and events for targeted analysis and storage optimization.

## 🎯 What You'll Get

### 📊 **Data Organization**
- **Custom buckets** for specialized log storage
- **Routing rules** to direct logs to specific buckets
- **Storage optimization** through targeted data placement
- **Query performance** improvements with focused datasets

### 🔄 **Automated Management**
- **Configuration as code** for bucket definitions
- **Routing rule automation** for log classification
- **Version control** for bucket configurations
- **Consistent deployment** across environments

## 📋 Prerequisites

- **Monaco**: `v2.9.0+`
- **Dynatrace Platform**: Environment with Grail enabled
- **OAuth Client**: With bucket permissions
- **API Token**: With appropriate scopes

### Required Permissions
```
OAuth Client Scopes:
- Read and write custom Grail buckets
- Read and write log routing rules

API Token Scopes:
- Read and write custom Grail buckets
- Read and write log routing rules
```

## 🛠️ Quick Start

### 1. Set Up Environment Variables
```bash
# Configure your environment
export DT_ENV_ID="your-environment-id"
export DT_ENV_URL="https://your-environment.apps.dynatrace.com"
export API_TOKEN="your-api-token"
export CLIENT_ID="your-oauth-client-id"
export CLIENT_SECRET="your-oauth-client-secret"
```

### 2. Deploy Configuration
```bash
# Deploy custom bucket and routing rules
monaco deploy manifest.yaml
```

### 3. Verify Deployment
```bash
# Check bucket creation
# Navigate to Settings > Logs > Custom buckets in Dynatrace

# Check routing rules
# Navigate to Settings > Logs > Routing rules in Dynatrace
```

**Time to value: 20 minutes** ⚡

## 📁 Configuration Structure

```
grail_buckets/
├── manifest.yaml                    # Monaco manifest
├── bucket/
│   ├── config.yaml                 # Project configuration
│   ├── bucket.json                 # Custom bucket definition
│   └── log-bucket-rule.json        # Log routing rule
└── README.md
```

## 🎛️ Configuration Examples

### Custom Bucket Definition
```json
{
  "table": "logs",
  "displayName": "Security Logs",
  "retentionDays": 90
}
```

### Log Routing Rule
```json
{
  "enabled": true,
  "ruleName": "Security Logs Routing",
  "bucketName": "security-logs",
  "matcher": "matchesPhrase(content, \"security\")"
}
```

## 🔧 Customization Options

### Bucket Types
- **Security Logs**: Authentication, authorization, and security events
- **Application Logs**: Application-specific logging data
- **Infrastructure Logs**: System and infrastructure monitoring
- **Business Logs**: Business process and transaction logs

### Routing Criteria
```yaml
# Common routing patterns
routing_rules:
  - name: "error-logs"
    matcher: "matchesPhrase(content, \"ERROR\")"
    bucket: "error-logs"
  
  - name: "performance-logs"
    matcher: "matchesPhrase(content, \"performance\")"
    bucket: "performance-logs"
  
  - name: "audit-logs"
    matcher: "matchesPhrase(content, \"audit\")"
    bucket: "audit-logs"
```

### Retention Policies
```yaml
# Retention configuration
retention_policies:
  - bucket: "security-logs"
    days: 365  # Long retention for compliance
  
  - bucket: "debug-logs"
    days: 7    # Short retention for debugging
  
  - bucket: "business-logs"
    days: 90   # Medium retention for business analysis
```

## 🚨 Use Cases

### 1. **Security Monitoring**
```yaml
# Security-focused bucket
security_bucket:
  name: "security-events"
  retention: 365 days
  routing:
    - authentication_events
    - authorization_failures
    - security_alerts
```

### 2. **Application Performance**
```yaml
# Performance monitoring bucket
performance_bucket:
  name: "app-performance"
  retention: 30 days
  routing:
    - response_time_logs
    - error_logs
    - throughput_metrics
```

### 3. **Compliance & Audit**
```yaml
# Compliance bucket
compliance_bucket:
  name: "audit-trail"
  retention: 7 years
  routing:
    - data_access_logs
    - configuration_changes
    - user_actions
```

## 📊 Log Analysis

### Using Dynatrace Log Viewer
Once logs are routed to custom buckets, you can analyze them using:

1. **Log Viewer**: Navigate to Logs in Dynatrace
2. **Bucket Selection**: Choose your custom bucket from the dropdown
3. **DQL Queries**: Use Dynatrace Query Language to search and filter
4. **Log Analytics**: Create dashboards and alerts based on log data

### Example DQL Queries
```dql
# Query logs in custom bucket
fetch logs
| filter log.source == "security-service"
| filter dt.entity.service == "authentication-service"
| summarize count(), by: {timestamp: bin(5m)}
```

## 🔍 Troubleshooting

### Common Issues

**1. Bucket Not Created**
```bash
# Check OAuth permissions
# Verify bucket syntax
# Check Monaco logs
```

**2. Routing Rule Not Working**
```bash
# Verify rule syntax
# Check matcher expression
# Test with sample logs
```

**3. Logs Not Routing**
```bash
# Check log format
# Verify matcher criteria
# Test with sample logs
```

### Debug Commands
```bash
# Validate configuration
monaco validate manifest.yaml

# Dry run deployment
monaco deploy manifest.yaml --dry-run

# Check bucket status
# Navigate to Settings > Logs > Custom buckets
```

## 🏆 Best Practices

### 1. **Bucket Design**
- Use descriptive names and descriptions
- Plan retention policies based on compliance needs
- Keep bucket count manageable
- Regular review and cleanup

### 2. **Routing Rules**
- Start with simple matchers and expand
- Test routing rules with sample data
- Monitor routing performance
- Regular validation of log routing

### 3. **Storage Optimization**
- Use appropriate retention periods
- Route logs to minimize storage costs
- Regular cleanup of unused buckets
- Monitor storage usage and costs

### 4. **Log Analysis**
- Use consistent log formats
- Implement structured logging
- Create meaningful log messages
- Regular log analysis and optimization

## 🤝 Community Support

- **Questions?** [Open an issue](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples/issues)
- **Improvements?** [Contribute](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples/pulls)

## 📚 Additional Resources

- **[Grail Data Model Documentation](https://www.dynatrace.com/support/help/platform/grail/data-model)**
- **[Custom Grail Buckets Guide](https://www.dynatrace.com/support/help/platform/grail/data-model#custom-grail-buckets)**
- **[Log Routing Documentation](https://docs.dynatrace.com/docs/shortlink/log-routing)**
- **[Dynatrace Query Language (DQL)](https://docs.dynatrace.com/docs/shortlink/dql)**
- **[Monaco Configuration Guide](https://docs.dynatrace.com/docs/shortlink/monaco)**

---

**Ready to organize your logs?** Start with the quick setup above! 🚀 