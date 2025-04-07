# AzureDevOps Releases & Builds Integration

The purpose is to help you integrate your AzureDevops Releases and Builds with Dynatrace in order to visualize statistics, execution logs and alerts.

## Prerequisites

1. [Install Dynatrace Configuration as Code via Monaco](https://docs.dynatrace.com/docs/deliver/configuration-as-code/monaco/installation)

2. [Create an OAuth client](https://docs.dynatrace.com/docs/deliver/configuration-as-code/monaco/guides/create-oauth-client) with the following permissions.
    * Run apps: `app-engine:apps:run`
    * View OpenPipeline configurations: `openpipeline:configurations:read`
    * Edit OpenPipeline configurations: `openpipeline:configurations:write`
    * Create and edit documents: `document:documents:write`
    * View documents: `document:documents:read`

3. Store the retrieved client ID, secret, and token endpoint as an environment variable.
<!-- windows version -->
```
$env:OAUTH_CLIENT_ID='<YOUR_CLIENT_ID>'
$env:OAUTH_CLIENT_SECRET='<YOUR_CLIENT_SECRET>'
$env:OAUTH_TOKEN_ENDPOINT='https://sso.dynatrace.com/sso/oauth2/token'
```
<!-- linux / macOS version -->
```
export OAUTH_CLIENT_ID='<YOUR_CLIENT_ID>'
export OAUTH_CLIENT_SECRET='<YOUR_CLIENT_SECRET>'
export OAUTH_TOKEN_ENDPOINT='https://sso.dynatrace.com/sso/oauth2/token'
```

4. Clone the [Dynatrace configuration as code sample](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples) repository and go to `github_pipeline_observability`.
```
git clone https://github.com/Dynatrace/dynatrace-configuration-as-code-samples.git
cd dynatrace-configuration-as-code-samples/azure_devops_observability
```

5. Edit the `manifest.yaml` by exchanging the `<YOUR-DT-ENV-ID>` placeholder with your Dynatrace environment ID.
```
manifestVersion: 1.0
projects:
  - name: pipeline_observability
environmentGroups:
  - name: group
    environments:
      - name: <YOUR-DT-ENV-ID>
        url:
          type: value
          value: https://<YOUR-DT-ENV-ID>.apps.dynatrace.com
        auth:
            oAuth:
              clientId:
                name: OAUTH_CLIENT_ID
              clientSecret:
                name: OAUTH_CLIENT_SECRET
              tokenEndpoint:
                type: environment
                value: OAUTH_TOKEN_ENDPOINT
```

## Steps 

### 1. Configure Dynatrace using Monaco

In this section, you will upload two Dashboards:
* AzureDevOps Dashboard (on Logs): Dashboard to observe release and build activities via logs.
* AzureDevOps Dashboard (on Events): Dashboard to observe release and build activities via events.

Run the following command to apply the provided configuration. 

```
monaco deploy manifest.yaml
```

### 2. Configure AzureDevOps

### Create Dynatrace Access Token

An access token is needed for Dynatrace to receive AzureDevOps Logs.

1. In Dynatrace, navigate to **Access Tokens**.
2. Click **Generate new token**.
3. Provide a descriptive name for your token.
4. Select the following scopes:
   - **Ingest Logs v2**
   - **Write Settings**
5. Click **Generate token**
6. Save the generated token securely for subsequent steps. It will be referred as `<YOUR-ACCESS-TOKEN>`.

### Create Webhooks in AzureDevops

First, we need to create two Service Hooks Subscriptions on Azure. One for **Builds** Completed and one for **Release Deployment** Completed. 

* You can create it on: `https://{orgName}/{project_name}/_settings/serviceHooks`
* [AzureDevOps Webhooks](https://learn.microsoft.com/en-us/azure/devops/service-hooks/services/webhooks?toc=%2Fazure%2Fdevops%2Fmarketplace-extensibility%2Ftoc.json&view=azure-devops)
* During the configuration, do not apply any filter
* In the settings page of the Subscription, you need to fill the following fields accordantly
  - URL: `https://<YOUR_TENANT_ID>.live.dynatrace.com/api/v2/logs/ingest`
  - HTTP Headers:
    - `"Authorization: Api-token <YOUR_LOG_INGEST_TOKEN>"`
    - **The text above must be written exactly like that. Copy and paste and just change the token**
  - Change "Messages to send" and "Detailed Messages to send" to **Text**

### 3. Configuring new Dynatrace Log Bucket

Follow the below steps to create a new logs bucket:

* Open the **Storage Management** app in your tenant
  - https://<YOUR_TENANT_ID>.apps.dynatrace.com/ui/apps/dynatrace.storage.management/
* Create a new bucket using the + sign on the top right corner
  - Setup the bucket name = **azure_devops_logs**
  - Set the retention time as desired
  - Set bucket type as logs

### 4. Configuring OpenPipeline - Log Processing Rules

* In Dynatrace, go to OpenPipeline > Logs > Pipelines
* Create a new pipeline, and name it "AzureDevOps"
* Go to Dynamic Routing and create the following new rule
  * `matchesPhrase(eventType,"ms.vss-release.deployment-completed-event") OR matchesPhrase(eventType,"build.complete")`
* Set the Pipeline dropdown to "AzureDevOps"
* Return back to your pipelines, and open AzureDevOps
* Under Storage section, add a new processor > Bucket assignment and set the storage to **azure_devops_logs** bucket.
* Go to Processing section:
  * Create a new rule for Rename Fields - "Rename Build Fields"
    * Add Name & Value pairs
      * buildNumber:`resource.buildNumber`
      * result:`resource.result`
  * Create a new rule for Rename Fields - "Rename Release Fields"
    * Add Name & Value pairs
      * stageName:`resource.stageName`
      * projectName:`resource.project.name`
      * releaseName:`resource.deployment.release.name`
      * releaseStatus:`resource.environment.status`
  * Add sample data to each of the new rules from logs to verify the rule is working as exepected.

### 5. Explore your Release and Build activities using the provided Dashboard

* In Dynatrace, go to Dashboards.
* Open: **AzureDevOps Dashboard (on Logs)** 

<img width="1480" alt="DT ADO Logs Dashboard" src="https://github.com/user-attachments/assets/da3229a5-c268-4d0e-8ff3-080f00f8a38e" />

---

## Advanced Mode

Taking this a step further, we can convert log data to events for each release and build, and discard the logs after to reduce the amount of unnecessary logs retained. 

### 6. Configuring OpenPipeline - Events Extraction

> **Disclaimer:** This how-to guide extracts [Business events](https://docs.dynatrace.com/docs/observe/business-analytics/ba-events-capturing#logs) from log lines. Currently, this is not possible for Software Development Lifecycle Events [(SDLC events)](https://docs.dynatrace.com/docs/deliver/pipeline-observability-sdlc-events/sdlc-events), which are the preferred way of storing the extract information. SDLC events are designed to 
> * Derive engineering KPIs to observe the health of the development pipelines.
> * Automate development and delivery processes such as test execution, release validation, or progressive delivery.
> * Fulfill compliance requirements by providing a complete end-to-end overview of the delivery process.

* Go to OpenPipeline > Logs > Pipelines > AzureDevOps
* Go to Data Extraction section:
  * Create a new rule Business Event Processor - "Build result"
    * Matching condition: `matchesPhrase(eventType,"build.complete")`
    * Event type: `eventType`
    * Event provider (change to Static String): `AzureDevOps`
    * Select *Fields to extract*
      * `result`
      * `buildNumber`
      * `resource.reason`
  * Create a new rule Business Event Processor - "Release result"
    * Matching condition: `matchesPhrase(eventType,"ms.vss-release.deployment-completed-event")`
    * Event type: `eventType`
    * Event provider (change to Static String): `AzureDevOps`
    * Select *Fields to extract*
      * `stageName`
      * `projectName`
      * `releaseName`
      * `releaseStatus`
      * `resource.deployment.startedOn`
      * `resource.deployment.completedOn`
      
##### (Optional) - Davis Events Extraction
* Go to Data Extraction section:
  * Create a new rule *Davis* Event Processor - "Build complete failed"
    * Matching condition: `matchesPhrase(eventType,"build.complete") AND result=="failed"` 
    * Event Name: `Build Complete Failed`
    * Event Description: `Unable to generate build {buildNumber}`
    * *event.type* can be changed from CUSTOM_ALERT to increase the severity level. (listed below)
  * Create a new rule *Davis* Event Processor - "Release Rejected"
    * Matching condition: `matchesPhrase(eventType,"ms.vss-release.deployment-completed-event") and releaseStatus == "rejected"` 
    * Event Name: `Release deployment rejected`
    * Event Description: `Unable to deploy release {releaseName}`
    * *event.type* can be changed from CUSTOM_ALERT to increase the severity level. (listed below)
  * Available event types:
    * `AVAILABILITY_EVENT`
    * `CUSTOM_ALERT`
    * `CUSTOM_ANNOTATION`
    * `CUSTOM_CONFIGURATION`
    * `CUSTOM_DEPLOYMENT`
    * `CUSTOM_INFO`
    * `ERROR_EVENT`
    * `MARKED_FOR_TERMINATION`
    * `PERFORMANCE_EVENT`
    * `RESOURCE_CONTENTION_EVENT`

### 7. Explore your Release and Build activities using the provided Dashboard

* In Dynatrace, go to Dashboards.
* Open: **AzureDevOps Dashboard (on Events)** 

<img width="1480" alt="DT ADO BizEvents Dashboard" src="https://github.com/user-attachments/assets/23b6ec2d-661f-48ab-9ed8-d32106be96b1" />


##### (Optional) - Discarding logs storage

Once the logs have been converted to Business and Davis events to extract the information required, we can go ahead and disable the storage assignment rule in the pipeline. 
* Go to OpenPipeline > Logs > Pipelines > AzureDevOps
* Under Storage > Bucket assignment Rule > Change the following rule:
  * Matching condition: `false`

## 🎉 You're all set, enjoy Dynatrace integration

- Keep in mind, you might need to request a Log Content Length (MaxContentLength_Bytes) increase depending on how many steps your Release Events have.

- The integration consumes DDUs for Log Ingest and Log Metrics and will depend on how many build/release events you have. For comparison purposes, a customer with 400 events was consuming around 1 DDU per week