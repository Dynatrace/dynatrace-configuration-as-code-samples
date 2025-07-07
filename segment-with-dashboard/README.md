# Dynatrace Segments with Dashboard Integration

> **Configure and manage Dynatrace Segments with automatic dashboard integration using Monaco**

This example demonstrates how to create and manage [Dynatrace Segments](https://docs.dynatrace.com/docs/manage/segments) using Monaco, with automatic integration into dashboards. Segments allow you to filter and group entities for targeted monitoring and analysis.

## 🎯 What You'll Get

### 📊 **Data Segmentation**
- **Entity filtering** based on custom criteria
- **Dynamic grouping** of related resources
- **Targeted monitoring** for specific environments
- **Dashboard integration** with automatic segment inclusion

### 🔄 **Automated Management**
- **Configuration as code** for segment definitions
- **Dashboard dependencies** with automatic linking
- **Version control** for segment configurations
- **Consistent deployment** across environments

## 📋 Prerequisites

- **Monaco**: `v2.19.0+`
- **Dynatrace Platform**: Environment with segments enabled
- **OAuth Client**: With segment permissions
- **API Token**: With appropriate scopes

### Required Permissions
```
OAuth Client Scopes:
- storage:filter-segments:read
- storage:filter-segments:write  
- storage:filter-segments:delete
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
# Deploy segments and dashboard
monaco deploy manifest.yaml
```

### 3. Verify Deployment
```bash
# Check segment creation
# Navigate to Settings > Segments in Dynatrace

# Check dashboard integration
# Navigate to Dashboards in Dynatrace
```

**Time to value: 15 minutes** ⚡

## 📁 Configuration Structure

```
segment-with-dashboard/
├── manifest.yaml                    # Monaco manifest
├── segments/
│   ├── _config.yaml                # Project configuration
│   ├── segment.json                # Segment definition
│   └── dashboard.json              # Dashboard with segment
└── README.md
```

## 🎛️ Configuration Examples

### Segment Definition
```json
{
  "name": "Production Services",
  "description": "All production services in the main environment",
  "rules": [
    {
      "type": "SERVICE",
      "enabled": true,
      "propagationTypes": ["SERVICE_TO_HOST_LIKE"],
      "conditions": [
        {
          "key": {
            "attribute": "SERVICE_TAG"
          },
          "comparisonInfo": {
            "type": "TAG",
            "operator": "EQUALS",
            "value": {
              "context": "CONTEXTLESS",
              "key": "environment",
              "value": "production"
            }
          }
        }
      ]
    }
  ]
}
```

### Dashboard with Segment
```json
{
  "dashboardMetadata": {
    "name": "Production Services Dashboard",
    "description": "Monitoring dashboard for production services"
  },
  "tiles": [
    {
      "name": "Service Response Time",
      "tileType": "DATA_EXPLORER",
      "configured": true,
      "bounds": {
        "top": 0,
        "left": 0,
        "width": 456,
        "height": 152
      },
      "tileFilter": {
        "timeframe": "-1h"
      },
      "queries": [
        {
          "id": "A",
          "metric": "builtin:service.response.time",
          "spaceAggregation": "AVG",
          "timeAggregation": "DEFAULT",
          "splitBy": ["dt.entity.service"],
          "filterBy": {
            "nestedFilters": [],
            "criteria": []
          },
          "limit": 100,
          "enabled": true
        }
      ],
      "visualConfig": {
        "type": "GRAPH_CHART",
        "graphChartConfig": {
          "legendShown": true,
          "type": "TIMESERIES",
          "series": [
            {
              "metric": "builtin:service.response.time",
              "aggregation": "AVG",
              "type": "LINE",
              "entityType": "SERVICE",
              "dimensions": [
                {
                  "id": "0",
                  "name": "dt.entity.service",
                  "values": [],
                  "entityDimension": true
                }
              ],
              "sortAscending": false,
              "sortColumn": true,
              "aggregationRate": "TOTAL"
            }
          ],
          "resultMetadata": {}
        }
      }
    }
  ]
}
```

## 🔧 Customization Options

### Segment Types
- **Service Segments**: Filter by service properties
- **Host Segments**: Filter by host characteristics
- **Application Segments**: Filter by application attributes
- **Custom Segments**: Filter by any entity type

### Filtering Criteria
```yaml
# Common filtering options
filters:
  - tags: "environment=production"
  - management_zones: "production-zone"
  - service_types: "web-service"
  - host_groups: "production-hosts"
  - custom_properties: "team=platform"
```

### Dashboard Integration
- **Automatic inclusion** of segment filters
- **Dynamic tile filtering** based on segments
- **Cross-segment analysis** capabilities
- **Real-time updates** when segments change

## 🚨 Use Cases

### 1. **Environment-Based Monitoring**
```yaml
# Production vs Development
segments:
  - name: "Production Services"
    filter: "environment=production"
  - name: "Development Services" 
    filter: "environment=development"
```

### 2. **Team-Based Segmentation**
```yaml
# Team ownership
segments:
  - name: "Platform Team Services"
    filter: "team=platform"
  - name: "Application Team Services"
    filter: "team=application"
```

### 3. **Service Type Segmentation**
```yaml
# Service categorization
segments:
  - name: "Critical Services"
    filter: "criticality=high"
  - name: "Background Services"
    filter: "service_type=background"
```

## 📊 Dashboard Features

### Automatic Segment Integration
- **Segment filters** applied to all tiles
- **Dynamic content** based on segment membership
- **Cross-segment analysis** capabilities
- **Real-time updates** when entities join/leave segments

### Visualization Options
- **Time series charts** with segment filtering
- **Top lists** showing segment members
- **Heat maps** with segment-based grouping
- **Custom metrics** filtered by segments

## 🔍 Troubleshooting

### Common Issues

**1. Segment Not Created**
```bash
# Check OAuth permissions
# Verify segment syntax
# Check Monaco logs
```

**2. Dashboard Not Updated**
```bash
# Verify segment reference
# Check dashboard configuration
# Validate Monaco deployment
```

**3. Filter Not Working**
```bash
# Check entity attributes
# Verify filter syntax
# Test with simple filters first
```

### Debug Commands
```bash
# Validate configuration
monaco validate manifest.yaml

# Dry run deployment
monaco deploy manifest.yaml --dry-run

# Check segment status
# Navigate to Settings > Segments
```

## 🏆 Best Practices

### 1. **Segment Design**
- Use descriptive names and descriptions
- Keep segments focused and specific
- Document segment purpose and criteria
- Regular review and cleanup

### 2. **Dashboard Integration**
- Test segments before dashboard integration
- Use consistent naming conventions
- Monitor dashboard performance
- Regular validation of segment membership

### 3. **Configuration Management**
- Version control all segment definitions
- Use consistent tagging strategies
- Document dependencies between segments
- Regular backup of configurations

## 🤝 Community Support

- **Questions?** [Open an issue](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples/issues)
- **Improvements?** [Contribute](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples/pulls)

## 📚 Additional Resources

- **[Dynatrace Segments Documentation](https://docs.dynatrace.com/docs/manage/segments)**
- **[Monaco Configuration Guide](https://docs.dynatrace.com/docs/shortlink/monaco)**
- **[Dashboard Best Practices](https://docs.dynatrace.com/docs/shortlink/dashboards)**

---

**Ready to segment your monitoring?** Start with the quick setup above! 🚀