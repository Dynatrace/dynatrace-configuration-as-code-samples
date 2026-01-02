# Modules

Modules are a Terraform design pattern to allow you to template configurations and deploy consistently. Refer to [Terraform documentation](https://developer.hashicorp.com/terraform/language/modules) for full details.

This repository contains modules for Synthetic Monitors - specifically HTTP and NAM.

Often Modules are maintained by a central team, to allow for standardization of naming standards and tags.

In the synthetics provided here, they implement a tag with the key `Application` and also include the value within the name of the synthetic.
```
name [application]
```