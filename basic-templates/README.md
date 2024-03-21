# Dynatrace Basic Templates

This repository will help you deploy a few basic templates and allow you to have a headstart when working with Monaco. All configuration is deployed automatically using **Dynatrace Configuration as Code solution Monaco**.

## Description 

The repository consists of 2 folders:

    1. env_variables
        - Default script that will run before Monaco runs to make sure all environment variables are exported properly
    2. monaco
        - Contains all json and yaml configurations needed to deploy everything to your Dynatrace environment


In general, the provided example in this repository serves as a practical guide to gaining a comprehensive understanding of the fundamentals of configuration as code with Monaco in the context of Dynatrace. By leveraging the templates and configurations included, users can initiate and streamline the deployment of essential components within their Dynatrace environment. The key configurations covered in this example encompass various aspects of Dynatrace settings/configurations:

    1. Alerting Profile Configuration 
        - Establish default filters for alerting profiles. Users are encouraged to review the configuration and customize it to align with their specific monitoring requirements.
    2. Application Detection Rule 
        - Set up default filters for application detection rules, allowing users to identify and define applications effectively. As with other configurations, customization is recommended based on individual needs.
    3. Web Application Configuration 
        - Create a web application with default filters, offering a starting point for users to configure web applications according to their monitoring criteria.
    4. Synthetic Monitor Setup 
        - Configure synthetic monitors with specific tags applied. Users should refer to the provided configuration for customization options.
    5. Maintenance Window Configuration 
        - Define a default maintenance window set to a weekly schedule. Users are advised to adjust this schedule to fit their specific maintenance needs.
    6. Management Zone Definition
        - Establish a management zone with certain tags applied. This configuration provides a foundation for managing and organizing monitored entities within the Dynatrace environment.
    7. Ownership Configuration
        - Set up ownership configurations to assign responsibility for specific entities. Users are encouraged to review and customize these configurations to reflect their organizational structure.
    8. Problem Notification Configuration
        - Configure problem notifications based on specific criteria. Users should tailor these configurations to align with their incident response and notification preferences.
    9. Service Level Objectives (SLOs)
        - Define service level objectives with default settings. Users can adapt these configurations to match the desired performance and reliability standards for their applications and services.

By exploring and deploying these configurations, users will gain practical insights into the implementation of Dynatrace Configuration as Code using Monaco. The provided example not only facilitates a head start in utilizing Monaco but also encourages users to adapt and customize configurations based on their unique monitoring and management requirements.

## Getting started with basic templates

To get started with Dynatrace Configuration as Code please see [the documentation](https://www.dynatrace.com/support/help/setup-and-configuration/monitoring-as-code).

To download the CLI, head over to the [dynatrace-configuration-as-code GitHub repository](https://github.com/Dynatrace/dynatrace-configuration-as-code/releases).

If you're new to Monaco and want to learn more, check out the [Observability Clinic on Monaco 2.0](https://dt-url.net/monaco-observability-clinic).

After your Monaco setup is done, and you have some practice, feel free to deploy this configuration and explore it in your tenant. 
To deploy it, please follow the steps below:

    1. Fill out the default.sh in the env_variables folder.   
    2. Run the script to export the variables - execute "source env_variables/default.sh"
    3. Run "monaco deploy manifest.yaml --dry-run" to very syntax of all files is correct.
    4. Run the monaco project with "monaco deploy manifest.yaml"
    5. Explore your Dynatrace environment and check out what got deployed

In case you need to **delete** the configuration, feel free to explore the [delete command](https://docs.dynatrace.com/docs/manage/configuration-as-code/monaco/reference/commands#delete).

Author: Danilo Vukotic - danilo.vukotic@dynatrace.com

