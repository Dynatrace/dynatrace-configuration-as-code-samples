# VM Right-Sizing with Dynatrace Automation

> **Automated Azure VM optimization using Dynatrace Automation Workflows and Jira approval system**

This example demonstrates how to automatically detect and right-size improperly sized Azure virtual machines using Dynatrace Automation Workflows. It integrates with Jira for approval workflows and Slack for notifications to optimize infrastructure costs and improve operational efficiency.

## 🎯 What You'll Get

### 📊 **Automated Azure VM Optimization**
- **CPU monitoring** with intelligent sizing recommendations
- **Jira approval workflow** for change management and governance
- **Automated Azure VM resizing** based on usage patterns
- **Slack notifications** for team awareness and transparency

### 🔄 **Integration Capabilities**
- **Jira**: Ticket creation and approval workflows for governance
- **Slack**: Real-time notifications and team collaboration
- **Azure**: Direct VM management and optimization
- **Dynatrace**: Intelligent monitoring and recommendations

### 💰 **Business Impact**
- **Reduce cloud costs** by 20-40% through automated optimization
- **Improve resource utilization** with data-driven recommendations
- **Streamline approval processes** with automated workflows
- **Maintain governance** while enabling automation

## 🚀 Quick Start

### Prerequisites
- Azure environment with VM resources
- Dynatrace environment with Automation Workflows
- Jira instance for approval workflows
- Slack workspace for notifications
- API tokens with appropriate permissions

### Deploy VM Optimization
```bash
# Clone and navigate to the sample
cd VM-RIght-Sizing

# Deploy the VM optimization configuration
monaco deploy manifest.yaml
```

## 📋 Configuration Overview

### Workflow Components
The sample includes three main workflow components:

1. **Jira Connection**: Automated ticket creation and approval management
2. **Slack Connection**: Real-time notifications and team communication
3. **Calculate Ticket Workflow**: Intelligent VM sizing recommendations

### Automation Process
The complete automation workflow:

1. **Monitor VM performance** using Dynatrace metrics
2. **Analyze resource utilization** patterns over time
3. **Generate optimization recommendations** based on usage data
4. **Create Jira tickets** for approval workflows
5. **Send Slack notifications** for team awareness
6. **Execute VM resizing** upon approval
7. **Monitor post-optimization** performance and costs

## 🔧 Customization Options

### Optimization Thresholds
Adjust the optimization criteria to match your requirements:

```yaml
# Example optimization thresholds
cpu_utilization:
  underutilized: < 20%
  overutilized: > 80%
  optimization_threshold: 30%

memory_utilization:
  underutilized: < 30%
  overutilized: > 85%
  optimization_threshold: 40%

cost_savings:
  minimum_savings: 15%
  approval_required: true
  auto_optimize: false
```

### Integration Customization
- **Jira fields**: Customize ticket creation and approval workflows
- **Slack channels**: Configure notification channels and message formats
- **Azure policies**: Set resource optimization policies and limits
- **Approval workflows**: Define approval hierarchies and escalation rules

## 📈 Success Metrics

### Cost Optimization KPIs
- **Cost Reduction**: 20-40% reduction in VM costs
- **Resource Utilization**: 70-80% average utilization
- **Optimization Frequency**: Monthly automated reviews
- **Approval Efficiency**: 90%+ approval rate for recommendations

### Business Value
- **Direct Cost Savings**: Reduced cloud infrastructure spending
- **Operational Efficiency**: Automated resource management
- **Governance Compliance**: Maintained approval workflows
- **Team Productivity**: Reduced manual optimization tasks

## 🛠️ Advanced Features

### Multi-Environment Support
- **Development**: Automated testing and validation
- **Staging**: Pre-production optimization testing
- **Production**: Full optimization with governance

### Custom Optimization Rules
- **Application-specific**: Tailored optimization for different workloads
- **Business hours**: Time-based optimization recommendations
- **Seasonal patterns**: Account for seasonal usage variations
- **Compliance requirements**: Ensure optimization meets compliance needs

### Automated Responses
- **Auto-optimization**: For low-risk, high-savings recommendations
- **Manual approval**: For complex or high-impact changes
- **Rollback capability**: Automatic rollback if performance degrades
- **Performance monitoring**: Continuous monitoring post-optimization

## 🔍 Troubleshooting

### Common Issues
1. **Workflow not triggering**: Check Azure integration and API permissions
2. **Jira integration failing**: Verify webhook URLs and authentication
3. **Optimization recommendations**: Review thresholds and adjust based on patterns
4. **Performance degradation**: Monitor post-optimization metrics closely

### Debug Steps
1. **Check workflow logs** in Dynatrace Automation
2. **Verify Azure metrics** are being collected properly
3. **Test Jira integration** with sample tickets
4. **Review optimization rules** and threshold settings

## 📚 Related Examples

- **[Site Reliability Guardian](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples/tree/main/site_reliability_guardian_sample)**: Quality gates and deployment validation
- **[Well-Architected Framework](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples/tree/main/well_architected_framework_validation)**: Cloud compliance and cost optimization
- **[Pipeline Observability](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples/tree/main/github_pipeline_observability)**: CI/CD monitoring and optimization

## 🤝 Community Support

- **Questions?** [Open an issue](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples/issues)
- **Improvements?** [Contribute](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples/pulls)
- **Success Stories?** [Share your experience](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples/issues/new?template=success-story.md)

---

**Ready to optimize cloud costs and improve operational efficiency?** Deploy this VM optimization solution and start seeing immediate cost savings through automated resource management.

**Author**: Danilo Vukotic - danilo.vukotic@dynatrace.com

