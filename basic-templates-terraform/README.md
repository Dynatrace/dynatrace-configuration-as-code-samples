# Dynatrace Basic Templates

This repository will help you deploy a few basic templates and allow you to have a headstart when working with Terraform and Dynatrace. All configuration is deployed automatically using **Terraform**.

## Description 

The repository consists of 1 folder and a few Terraform files in the main directory:

    1. env_variables
        - Default script that will run before Terraform runs to make sure all environment variables are exported properly
    2. main.tf
        - Contains all terraform configuration needed to deploy everything to your Dynatrace environment
    3. providers.tf
        - Contains the Dynatrace Terraform provider - https://registry.terraform.io/providers/dynatrace-oss/dynatrace/latest/docs
    4. variables.tf
        - Contains all defined environment variables 


In general, the provided example in this repository serves as a practical guide to gaining a comprehensive understanding of the fundamentals of configuration as code with Terraform in the context of Dynatrace. By leveraging the templates and configurations included, users can initiate and streamline the deployment of essential components within their Dynatrace environment. The key configurations covered in this example encompass various aspects of Dynatrace settings/configurations:

    1. Alerting Profile Configuration 
        - Establish default filters for alerting profiles. Users are encouraged to review the configuration and customize it to align with their specific monitoring requirements.
    2. Web Application Configuration 
        - Create a web application with default filters, offering a starting point for users to configure web applications according to their monitoring criteria.
    3. Application Detection Rule 
        - Set up default filters for application detection rules, allowing users to identify and define applications effectively. As with other configurations, customization is recommended based on individual needs.
    4. Synthetic Monitor Setup 
        - Configure synthetic monitors with specific tags applied. Users should refer to the provided configuration for customization options.
    5. Auto Tag Creation 
        - Define an auto tag configuration. Users are encouraged to review the configuration and customize it to align with their specific monitoring requirements.
    6. Management Zone Definition
        - Establish a management zone with certain tags applied. This configuration provides a foundation for managing and organizing monitored entities within the Dynatrace environment.
    7. Ownership Configuration
        - Set up ownership configurations to assign responsibility for specific entities. Users are encouraged to review and customize these configurations to reflect their organizational structure.
    8. Ownership Teams
        - Set up ownership teams to make sure you are aware of the responsibility that exists in your environment. Users are encouraged to review and customize these configurations to reflect their organizational structure.
    9. Problem Notification Configuration
        - Configure problem notifications based on specific criteria. Users should tailor these configurations to align with their incident response and notification preferences.
    10. Service Level Objectives (SLOs)
        - Define service level objectives with default settings. Users can adapt these configurations to match the desired performance and reliability standards for their applications and services.

By exploring and deploying these configurations, users will gain practical insights into the implementation of Dynatrace Configuration as Code using Terraform. The provided example not only facilitates a head start in utilizing Terraform but also encourages users to adapt and customize configurations based on their unique monitoring and management requirements.

## Getting started with basic templates

To get started with Dynatrace Configuration as Code please see [the documentation](https://www.dynatrace.com/support/help/setup-and-configuration/monitoring-as-code).

To install the CLI, head over to the [install terraform CLI documentation](https://docs.dynatrace.com/docs/deliver/configuration-as-code/terraform/terraform-cli).

If you're new to Terraform and want to learn more, check out the [Getting Started with Dynatrace Terraform](https://www.youtube.com/watch?v=uAudyJNpda0&t=3746s).

After your Terraform setup is done, and you have some practice, feel free to deploy this configuration and explore it in your tenant. 
To deploy it, please follow the steps below:

    1. Fill out the default.sh in the env_variables folder.   
    2. Run the script to export the variables - execute "source env_variables/default.sh"
    3. Run "terraform init" to initiate and fetch the Dynatrace Terraform provider.
    4. Run "terraform plan" to verify syntax of all files and see what will be deployed into your tenant.
    5. Run "terraform apply" to apply your configuration.
    6. Explore your Dynatrace environment and check out what got deployed

In case you need to **delete** the configuration, feel free to run "terraform destroy". Feel free to refer to [delete configuration documentation page](https://docs.dynatrace.com/docs/deliver/configuration-as-code/terraform/teraform-basic-example#delete-the-configuration).

Author: Danilo Vukotic - danilo.vukotic@dynatrace.com

