# Modules

This repository is an example of how to create company specific modules for resources to enable best practice deployment, and easy integration with input files and data sources. 

# Getting started

To use this repository you will need to create an API token with the ability to manage Synthetic monitors, the scope for which is described on the [HTTP resource](https://registry.terraform.io/providers/dynatrace-oss/dynatrace/latest/docs/resources/http_monitor) and [Network Monitor Resource](https://registry.terraform.io/providers/dynatrace-oss/dynatrace/latest/docs/resources/network_monitor).

## File Structure

- **synthetics/http/**: Terraform module for HTTP synthetic monitors
- **synthetics/nam/**: Terraform module for NAM (Network Availability Monitor) synthetic monitors
- **synthetics/examples/**: Example configurations and input files for synthetic monitors
- **synthetics/README.md**: Additional documentation specific to the use of the synthetics modules


# Modules Details
Modules are a Terraform design pattern to allow you to template configurations and deploy consistently. Refer to [Terraform documentation](https://developer.hashicorp.com/terraform/language/modules) for full details.

This repository contains modules for Synthetic Monitors - specifically HTTP and NAM.

Often Modules are maintained by a central team, to allow for standardization of naming standards and tags.

In the synthetics provided here, they implement a tag with the key `Application` and also include the value within the name of the synthetic.
```
name [application]
```

# Contributing
Contributions are welcome! Please open issues or submit pull requests to help improve this repository. Suggestions for new patterns, bug fixes, or documentation improvements are appreciated.