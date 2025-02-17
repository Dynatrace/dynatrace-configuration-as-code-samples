# 🚀 AzureDevOps Releases & Builds Integration
The purpose is to help you integrate your AzureDevops Releases and Builds with Dynatrace in order to visualize statistics, execution logs and alerts.


### 📋 Step 1 - Pre-requisites

- Access to your Dynatrace Tenant and permission to create tokens
- Your tenant ID. Which can be found on your environment URL. https://<YOUR_TENANT_ID>.live.dynatrace.com/
- A token with **Ingest Logs v2** scope
- A token with **Write Settings** scope

### 🪝 Step 2 - Creating Webhooks in AzureDevops

 - First, we need to create two Service Hooks Subscriptions on Azure. One for **Builds** Completed and one for **Release Deployment** Completed. 
	 - You can create it on `https://{orgName}/{project_name}/_settings/serviceHooks`
	 - [AzureDevOps Webhooks](https://learn.microsoft.com/en-us/azure/devops/service-hooks/services/webhooks?toc=%2Fazure%2Fdevops%2Fmarketplace-extensibility%2Ftoc.json&view=azure-devops)
 - During the configuration, do not apply any filter
 - In the settings page of the Subscription, you need to fill the following fields accordantly
	 - URL: `https://<YOUR_TENANT_ID>.live.dynatrace.com/api/v2/logs/ingest`
	 - HTTP Headers:
		 - `"Authorization: Api-token <YOUR_LOG_INGEST_TOKEN>"`
		 - **The text above must be written exactly like that. Copy and paste and just change the token**
	 - Change "Messages to send" and "Detailed Messages to send" to **Text**
That's all you need in AzureDevops!

### 🪣 Step 3 - Configuring new Dynatrace Log Bucket

#### Follow the below steps to create a new logs bucket:
* Open the **Storage Management** app in your tenant
  - https://<YOUR_TENANT_ID>.apps.dynatrace.com/ui/apps/dynatrace.storage.management/
* Create a new bucket using the + sign on the top right corner
  - Setup the bucket name = **azure_devops_logs**
  - Set the retention time as desired
  - Set bucket type as logs

  ### 🧑‍💻 Step 4 - Configuring OpenPipeline - Log Processing Rules

#### 
* Go to OpenPipeline > Logs > Pipelines
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
  * Add sample data to each of the new rules from logs to verify the rule is working as exepected

  ### 🖥️ Step 5 - Dashboard Template (on Logs)
* Go to [AzureDevOps Git Repository](https://github.com/rohanshah-sre/AzureDevOps/tree/main), and download `AzureDevOps Dashboard (on Logs).json` file.
* Within Dynatrace, open the new Dashboards app, and press **Upload** button at the top left corner.
* Upload the json file to start visualizing your Azure DevOps data.

## 🧮 Advanced Mode

> Taking this a step further, we can convert log data to events for each release and build, and discard the logs after to reduce the amount of unnecessary logs retained. 

### 💼 Step 6 - Configuring OpenPipeline - Business Events Extraction

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
      
##### ⚠️ (Optional) - Davis Events Extraction
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

##### ⛓️‍💥 (Optional) - Discarding logs storage
Once the logs have been converted to Business and Davis events to extract the information required, we can go ahead and disable the storage assignment rule in the pipeline. 
* Go to OpenPipeline > Logs > Pipelines > AzureDevOps
* Under Storage > Bucket assignment Rule > Change the following rule:
  * Matching condition: `false`

### 🖥️ Step 7 - Dashboard Template (on Events)

* Go to [AzureDevOps Git Repository](https://github.com/rohanshah-sre/AzureDevOps/tree/main)﻿, and download `AzureDevOps Dashboard (on BizEvents).json` file.
* Within Dynatrace, open the new Dashboards app, and press Upload button at the top left corner.
* Upload the json file to start visualizing your Azure DevOps data.

### 📦 Step 8 - Segments
Segments are typically modeled to allow filtering monitored entities, logs, metrics, events, and other types of data. 

We will use it to filter *AzureDevOps* data
* Go to Segments App > Create a new segment using + sign on the top right corner
* Rename it to `AzureDevOps`
* Add Business events data type
  * Input `event.provider = AzureDevOps`
* Add Logs data type
  * Input `dt.system.bucket = azure_devops_logs`
* Press Save

## 🎉 You're all set, enjoy Dynatrace integration

 - Keep in mind, you might need to request a Log Content Length (MaxContentLength_Bytes) increase depending on how many steps your Release Events have.
 - The integration consumes DDUs for Log Ingest and Log Metrics and will depend on how many build/release events you have. For comparison purposes, a customer with 400 events was consuming around 1 DDU per week