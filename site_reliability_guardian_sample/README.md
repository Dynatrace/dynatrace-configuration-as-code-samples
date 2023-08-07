
# Site Reliability Guardian

This sample provides the configuration for a guardian in the [Site Reliability Guardian](https://www.dynatrace.com/support/help/platform-modules/cloud-automation/site-reliability-guardian) and an automation workflow leveraging [Workflows](https://www.dynatrace.com/support/help/platform-modules/cloud-automation/workflows).

## Prerequisites

- Monaco >`v2.6.0`
- Dynatrace Platform environment with [Site Reliability Guardian installed](https://www.dynatrace.com/support/help/platform-modules/cloud-automation/site-reliability-guardian#install-update-or-uninstall)
- OAuth client as described [here](https://www.dynatrace.com/support/help/manage/configuration-as-code/guides/create-oauth-client#create-an-oauth-client), including the additional scope: `app-engine:apps:run`

## Guardian

The guardian is designed to safeguard a Kubernetes workload running the *easytrade* application. Its objectives focus on resource utilization. 

To properly configure the objectives:
* Replace the `CLOUD_APPLICATION-PLACEHOLDER` variable with a Kubernetes workload ID.

## Workflow

The workflow has an event subscription listening on bizEvents that match the filter: `tag.application == "easytrade" and tag.stage == "production"`. After triggering the workflow, the validation of the guardian is executed and followed by two JavaScript actions. The two actions have a condition to act according to the validation result: `pass` and `failure`. Please note that the workflow does not cover the `warning` and `error` results. Feel free to adapt the JavaScript actions.