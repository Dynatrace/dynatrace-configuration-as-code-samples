# Dynatrace VM Right-Sizing Example

This repository will help you deploy a configuration that will right-size your infrastructure using Dynatrace Automation Workflows. All configuration is deployed automatically using Dynatrace Configuration as Code solution Monaco.

## Description 

The example will help you detect improperly sized hosts, trigger an approval workflow in external tools such as Jira, ServiceNow ... and then react to that approval with a workflow to right-size the environment based on metadata stored in tags by calling the respective infrastructure automation APIs such as Azure, GCP, AWS, Kubernetes, OpenShift, VMWare, Ansible.

Monaco will deploy 4 different configurations - Slack for Workflows, Jira for Workflows and two Workflows(Host Resize - Calculate & Ticket and Host Resize - Event Triggered). 

Here's a breakdown of what each workflow will do:

    1. Host Resize - Calculate & Ticket will use DQL to query the current CPU usage for hosts that belong to an Azure environment. It will also use a filter that will only take hosts that are either using above 90% or below 15% of CPU at any given time. 
    2. Workflow will open a Jira ticket(using Jira for workflows) with hosts that need to be resized.
    3. Workflow will move the ticket to pending automatically so it can be worked at.
    4. Workflow will send a notification to a slack channel(using Slack for workflows).
    5. In the Jira project, you need to go and define an automation that will react to the ticket that got moved to pending and send a POST event back to Dynatrace.
       - First automation - Auto approve pending - When issue transitioned from Open to Pending > Approve it. (Skip if there's a team who does this manually)
       - Second automation - Post event for approval - When approved by previous automation(or team) > Send web request (URL - e.g. https://<tenantId>.apps.dynatrace.com/api/v2/events/ingest)
        Payload:
                    {
                "eventType": "CUSTOM_INFO",
                "title": "Jira approval granted: {{issue.key}}",
                "properties": {
                   "issuekey": "{{issue.key}}",
                   "issueurl": "{{issue.url}}",
                   "issueid": "{{issue.id}}",
                   "issuedescription": "{{issue.description.replaceAll("(\n)",",")}}"
                      }
                    }
    6. Host Resize - Event Triggered will react to the event that Jira automation sent and use DQL to query, extract certain information, and make a decision which hosts need to be resied.
    7. Workflow will obtain a bearer token.
    8. Workflow will upsize/downize a Host based on certain conditions from previous steps.
    9. Workflow will close the Jira ticket.

To learn more about this use case, check out the [Dynatrace Tips & Tricks Community Episode](https://youtu.be/dGWlnd1lNGQ).

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

