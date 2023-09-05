# Dynatrace VM Right-Sizing Example

This repository will help you deploy a configuration that will right-size your infrastructure using Dynatrace Automation Workflows. All configuration is deployed automatically using Dynatrace Configuration as Code solution Monaco.

## Description 

The example will help you detect improperly sized hosts, trigger an approval workflow in external tools such as Jira, ServiceNow ... and then react to that approval with a workflow to right-size the environment based on metadata stored in tags by calling the respective infrastructure automation APIs such as Azure, GCP, AWS, Kubernetes, OpenShift, VMWare, Ansible.

## Getting started with VM-Right-Sizing

To get started with Dynatrace Configuration as Code please see [the documentation](https://www.dynatrace.com/support/help/setup-and-configuration/monitoring-as-code).

To download the CLI, head over to the [dynatrace-configuration-as-code GitHub repository](https://github.com/Dynatrace/dynatrace-configuration-as-code/releases).

If you're new to Monaco and want to learn more, check out the [Observability Clinic on Monaco 2.0](https://dt-url.net/monaco-observability-clinic).

After your Monaco setup is done and you have some practice, feel free to deploy this configuration and explore it in your tenant. 
To deploy it, please follow the steps below:

    1. Fill out the input-needed.sh as well as the environment url in the manifest.yaml file.   
    2. Run the script to record the values
    3. Run the monaco project
    4. Go to Settings>Dynatrace Apps>Slack/Jira to check your Slack and Jira connections and go to the new Workflows apps to check your 2 newly created workflows. 

In case you need to delete the configuration, feel free to run the monaco delete command with the delete.yaml.

Author: Danilo Vukotic - danilo.vukotic@dynatrace.com

