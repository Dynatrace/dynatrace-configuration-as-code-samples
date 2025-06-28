# Contributing to Dynatrace Configuration as Code Samples

Thank you for your interest in contributing to the Dynatrace Configuration as Code Samples repository! This guide will help you get started with contributing.

## 🤝 How to Contribute

### Quick Start
- [Start an issue](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples/issues) about your specific needs
- [Report bugs](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples/issues) you've found
- [Request features](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples/issues) you'd like to see
- [Improve documentation](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples/issues) by fixing typos or clarifying instructions

### Major Contributions
- **Add new examples** for common use cases
- **Enhance existing examples** with better practices
- **Create templates** for reusable configurations
- **Improve automation** and CI/CD integrations

## 📋 Before You Start

### Check Existing Work
1. **Check Existing Issues**: Search for similar issues or discussions
2. **Review Recent Changes**: Look at recent pull requests and commits
3. **Read Documentation**: Familiarize yourself with the existing examples

### Choose Your Contribution Type

| Type | Description | Effort | Impact |
|------|-------------|--------|--------|
| **Bug Fix** | Fix issues in existing examples | Low | High |
| **Documentation** | Improve READMEs and guides | Low | Medium |
| **Enhancement** | Improve existing examples | Medium | High |
| **New Example** | Add completely new use case | High | High |
| **Template** | Create reusable templates | Medium | Medium |

## 🛠️ Development Setup

### Prerequisites
- [Dynatrace Monaco CLI](https://github.com/Dynatrace/dynatrace-configuration-as-code/releases) (v2.0+)
- Dynatrace environment for testing
- Git and basic command line skills
- Understanding of YAML/JSON configuration

### Local Setup
```bash
# Clone the repository
git clone https://github.com/Dynatrace/dynatrace-configuration-as-code-samples.git
cd dynatrace-configuration-as-code-samples

# Create a new branch for your contribution
git checkout -b feature/your-contribution-name

# Make your changes and test them
# ...

# Commit and push
git add .
git commit -m "Add: description of your contribution"
git push origin feature/your-contribution-name
```

## 📝 Contribution Guidelines

### Code Style
- **Use consistent formatting** for YAML and JSON files
- **Follow existing naming conventions** for files and folders
- **Include comprehensive comments** in configuration files
- **Test your configurations** before submitting

### Documentation Standards
- **Write clear README.md** files for each example
- **Include prerequisites** and setup instructions
- **Provide step-by-step guides** for implementation
- **Add troubleshooting sections** for common issues
- **Include configuration examples** with explanations

### Example Structure
```
your-example/
├── README.md              # Comprehensive documentation
├── manifest.yaml          # Monaco manifest file
├── project/               # Configuration files
│   ├── config.yaml        # Project configuration
│   └── object.json        # Dynatrace object definition
├── env_variables/         # Environment variables (if needed)
│   └── default.sh
└── delete.yaml           # Cleanup configuration (optional)
```

## 🎯 What We're Looking For

### High-Impact Examples
- **Pipeline observability** for CI/CD platforms
- **Quality gates** and deployment validation
- **Infrastructure automation** and optimization
- **Service monitoring** and alerting strategies
- **Cost optimization** and resource management
- **Compliance monitoring** and validation

### Quality Standards
- **Production-ready** configurations
- **Well-documented** with clear instructions
- **Tested** in real environments
- **Follows best practices** for security and performance
- **Reusable** and adaptable to different environments

## 🔄 Pull Request Process

### Before Submitting
1. **Test thoroughly** in your Dynatrace environment
2. **Update documentation** to reflect your changes
3. **Follow the template** structure and naming conventions
4. **Include screenshots** or examples where helpful

### Pull Request Template
```markdown
## Description
Brief description of what this PR adds or changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Enhancement

## Testing
- [ ] Tested in Dynatrace environment
- [ ] Verified configuration deployment
- [ ] Checked documentation accuracy

## Checklist
- [ ] Code follows existing style guidelines
- [ ] Documentation is updated
- [ ] Configuration is tested
- [ ] README includes setup instructions
```

## 🚀 Getting Help

### Before Asking for Help
1. **Search existing issues and discussions**
2. **Check the documentation** for similar examples
3. **Review the existing codebase** for patterns

### When You Need Help
1. **Use the issues section** for general questions
2. **Provide context** about your environment and use case
3. **Include error messages** and configuration examples
4. **Be specific** about what you're trying to achieve

## 🌟 Recognition

### Contributors Hall of Fame
We recognize contributors in several ways:
- **Contributor badges** on your GitHub profile
- **Mention in release notes** for significant contributions
- **Featured examples** showcase for outstanding work
- **[GitHub Issues](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples/issues)** for community support

### Success Stories
Share how you've used these samples:
- **Create an issue** with your success story
- **Include metrics** and business impact
- **Describe challenges** and how you solved them
- **Provide feedback** for future improvements

## 📚 Resources

### Learning Materials
- **[Monaco Documentation](https://docs.dynatrace.com/docs/manage/configuration-as-code/monaco)**: Official configuration as code guide
- **[Dynatrace API Reference](https://docs.dynatrace.com/docs/shortlink/configuration-api)**: API documentation
- **[Community Examples](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples)**: Browse existing examples

### Support Channels
- **[GitHub Issues](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples/issues)**: Report bugs and request features
- **[Dynatrace Community](https://community.dynatrace.com/)**: Community forums and discussions
- **[Official Documentation](https://docs.dynatrace.com/docs/shortlink/monaco)**: Dynatrace help and guides

## 📄 License

By contributing to this project, you agree that your contributions will be licensed under the [Apache License 2.0](LICENSE).

---

**Ready to contribute?** Start by [browsing existing issues](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples/issues) or [creating a new one](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples/issues/new) to discuss your idea! 