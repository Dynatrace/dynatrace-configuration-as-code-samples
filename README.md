# Dynatrace Configuration as Code Samples

[![Monaco](https://img.shields.io/badge/Monaco-2.0+-blue.svg)](https://github.com/Dynatrace/dynatrace-configuration-as-code)
[![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)](LICENSE)
[![Issues](https://img.shields.io/badge/Issues-Open-blue.svg)](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples/issues)

> **The ultimate collection of production-ready Dynatrace configurations, templates, and best practices for modern observability teams.**

This repository provides battle-tested configuration as code examples for Dynatrace, designed to accelerate your observability implementation and deliver immediate business value. Whether you're a DevOps engineer, SRE, or platform team member, these samples will help you implement Dynatrace configurations at scale with confidence.

## 🚀 Quick Start

### Prerequisites
- [Dynatrace Monaco CLI](https://github.com/Dynatrace/dynatrace-configuration-as-code/releases) (v2.0+)
- Dynatrace environment with API access
- [API Token](https://docs.dynatrace.com/docs/manage/access-control/access-tokens#create-api-token) with appropriate permissions

### Deploy Your First Configuration
```bash
# Clone the repository
git clone https://github.com/Dynatrace/dynatrace-configuration-as-code-samples.git
cd dynatrace-configuration-as-code-samples

# Deploy a sample configuration
monaco deploy basic-templates-monaco/manifest.yaml
```

## 📚 Featured Examples

### 🏆 **Pipeline Observability** ⭐ **Featured**
*Reduce deployment failures and catch issues before production*
- **[GitHub Actions](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples/tree/main/github_pipeline_observability)** - Monitor GitHub workflows and pull requests with real-time insights
- **[GitLab CI/CD](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples/tree/main/gitlab_pipeline_observability)** - Track GitLab pipelines and merge requests for improved developer productivity  
- **[Azure DevOps](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples/tree/main/azure_devops_observability)** - Monitor Azure DevOps pipelines and work items with comprehensive analytics
- **[ArgoCD](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples/tree/main/argocd_observability)** - Track ArgoCD application deployments for GitOps excellence

### 🛡️ **Quality Gates & Compliance** ⭐ **Enterprise Premium**
*Prevent bad deployments and ensure cloud compliance automatically*
- **[Site Reliability Guardian](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples/tree/main/site_reliability_guardian_sample)** - Automated quality gates for deployment validation with immediate ROI
- **[Well-Architected Framework](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples/tree/main/well_architected_framework_validation)** - AWS WAF compliance monitoring with automated validation

### 🏗️ **Infrastructure & Operations** ⭐ **Cost Optimization**
*Optimize cloud costs and improve operational efficiency*
- **[VM Right-Sizing](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples/tree/main/VM-RIght-Sizing)** - Automated Azure VM optimization with Jira approval workflow
- **[Grail Buckets](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples/tree/main/grail_buckets)** - Log management and analysis with custom buckets for better troubleshooting
- **[Service Level Objectives](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples/tree/main/service-level-objectives)** - SLO implementation with custom SLIs for business alignment

## 🎯 What You'll Get

### 📊 **Production-Ready Configurations**
- **Battle-tested examples** used in real-world environments with proven ROI
- **Complete implementations** with all necessary components for immediate deployment
- **Best practices** for security, performance, and maintainability at scale
- **Multi-environment support** for dev, staging, and production with governance

### 🔧 **Comprehensive Coverage**
- **Pipeline observability** for all major CI/CD platforms with developer productivity insights
- **Quality gates** and compliance monitoring with automated validation
- **Infrastructure automation** and optimization with cost savings
- **Service monitoring** and alerting with reduced MTTR
- **Log management** and analysis with improved troubleshooting
- **Dashboard templates** and visualizations for executive reporting

### 🚀 **Accelerated Implementation**
- **Copy-paste ready** configurations that work out of the box
- **Step-by-step guides** for each example with clear business value
- **Troubleshooting tips** and common solutions for rapid deployment
- **Community support** through issues and examples for ongoing success

## 🌟 Community Showcase

### Success Stories
> "These samples helped us implement Dynatrace observability across our entire microservices architecture in just 2 weeks, reducing our deployment failures by 40%!" - *Platform Engineering Team*

> "The pipeline observability examples saved us months of development time and gave us insights we never had before, improving our developer productivity significantly." - *DevOps Lead*

> "The Site Reliability Guardian quality gates prevented 3 major production incidents in our first month, delivering immediate ROI." - *SRE Team*

**[Share your success story →](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples/issues/new?template=success-story.md)**

### Community Contributions
- **Pipeline integrations** for additional CI/CD platforms with market demand
- **Custom dashboard templates** for specific use cases and industries
- **Automation workflows** for common operational tasks with efficiency gains
- **Best practice guides** for specific industries and compliance requirements

## 📖 Getting Help

### Documentation & Resources
- **Monaco Documentation**: [Configuration as Code Guide](https://docs.dynatrace.com/docs/manage/configuration-as-code/monaco)
- **Dynatrace API**: [API Reference](https://docs.dynatrace.com/docs/shortlink/configuration-api)
- **Community**: [GitHub Issues](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples/issues)

### Support Channels
- **Issues**: [Report bugs or request features](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples/issues)
- **Documentation**: [Dynatrace Help](https://docs.dynatrace.com/docs/shortlink/monaco)
- **Community**: [Dynatrace Community](https://community.dynatrace.com/)

## 🤝 Contributing

We welcome contributions! Here's how you can help:

### Quick Contributions
1. **Share Your Use Cases**: [Create an issue](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples/issues) about your specific needs
2. **Report Issues**: Help us improve by reporting bugs or suggesting enhancements
3. **Improve Documentation**: Fix typos, clarify instructions, or add missing information

### Major Contributions
1. **Add New Examples**: Create new sample configurations for common use cases
2. **Enhance Existing Examples**: Improve existing samples with better practices
3. **Create Templates**: Develop reusable configuration templates

See our [Contributing Guide](CONTRIBUTING.md) for detailed instructions.

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## 🔗 Related Projects

- **[Dynatrace Monaco](https://github.com/Dynatrace/dynatrace-configuration-as-code)** - The official Configuration as Code tool
- **[Dynatrace Terraform Provider](https://github.com/dynatrace-oss/terraform-provider-dynatrace)** - Terraform integration for Dynatrace
- **[Dynatrace Community](https://community.dynatrace.com/)** - Community forums and resources

---

**Ready to accelerate your Dynatrace implementation and deliver immediate business value?** Start with one of our [featured examples](#-featured-examples) or explore the [full collection](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples/tree/main) of samples.
