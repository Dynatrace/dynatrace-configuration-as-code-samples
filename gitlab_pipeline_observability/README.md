# Observe your GiLab Merge Requests and Pipelines with Dashboards and normalized SDLC events through OpenPipeline

Enable Platform Engineering teams to grasp and analyze the efficiency of GitLab pipelines and processes bound to GitLab merge requests to drive improvements and optimize the Internal Development Platform (IDP). By better understanding the integration of GitLab into your development routines or delivery processes, you can set actions in the following directions:

* *Streamlining CI/CD Pipelines*: Observing pipeline executions allows you to identify bottlenecks and inefficiencies in your CI/CD pipelines. This helps in optimizing build and deployment processes, leading to faster and more reliable releases.

* *Improving Developer Productivity*: Automated pipelines reduce the manual effort required for repetitive tasks, such as running tests and checking coding standards. This allows developers to focus more on writing code and less on administrative tasks.

* *Data-Driven Insights*: Analyzing telemetry data from merge requests and pipelines provides valuable insights into the development process. This data can be used to make informed decisions and continuously improve the development flows.

## Target audience

This article is intended for Platform Engineers managing the internal Development Platform (IDP), including GitLab for an entire organization.

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

4. Clone the [Dynatrace configuration as code sample](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples) repository and go to `gitlab_pipeline_observability`.
```
git clone https://github.com/Dynatrace/dynatrace-configuration-as-code-samples.git
cd gitlab_pipeline_observability
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

In this section, you will upload two Dashboards and configure the ingest endpoint for GitLab Webhooks in Dynatrace. Before you continue, please check your OpenPipeline configuration for *Software development lifecycle events*.

1. In Dynatrace, navigate to **OpenPipeline**.
2. Expand **Events** and click **Software development lifecycle**.
3. Open **Ingest source** and check if another ingest source exists except the built-in *Endpoint for Software Development*.
4. Open **Dynamic routing** and check if another route exists excpet the *Default route*.
5. Open **Pipelines** and check if another pipeline exists except the built-in *events.sdlc*. 
6. If you  have the default and built-in configuration, you can run Monaco to deploy the provided configuration; otherwise, you must merge the configuration file before updating it. 

#### Run Monaco deploy

Run the following command to apply the provided configuration. 

```
monaco deploy manifest.yaml
```

#### Merge configuration before running Monaco deploy

1. Download your OpenPipeline configuration.
```
monaco download
```

2. Merge the content of `download_<DATE>_<NUMBER>\project\openpipline\events.sdlc.json` into the file `events.sdlc.github.json`.

3. Run the following command to apply the provided configuration. 
```
monaco deploy manifest.yaml
```

### 2. Configure GitLab to send Webhook events to Dynatrace

#### Create Dynatrace Access Token

An access token with *openpipeline scopes* is needed for Dynatrace to receive GitLab webhook events processed by OpenPipeline. 

1. In Dynatrace, navigate to **Access Tokens**.
2. Click **Generate new token**.
3. Provide a descriptive name for your token.
4. Select the following scopes:
   - `openpipeline.events_sdlc.custom` 
   - `openpipeline.events_sdlc`
5. Click **Generate token**
6. Save the generated token securely for subsequent steps. It will be referred as `<YOUR-ACCESS-TOKEN>`.
​
#### Configure GitLab Webhook

You can configure webhooks at either the group level (affecting all repositories in a given group) or the repository level. 

1. In GitLab, select your group or repository.
2. Go to **Settings** > **Webhooks**.
3. Click **Add new webhook**.
4. Configure the following settings:
   - **URL**: Please exchange the placeholder `<YOUR-DT-ENV-ID>`  with your Dynatrace environment ID , respectively.<br><br>
     
    ```
    https://<YOUR-DT-ENV-ID>.live.dynatrace.com/platform/ingest/custom/events.sdlc/gitlab
     ```
   - **Custom headers**
     - Click **Add custom header**
     - Set the **Header name** to `Authorization`
     - Set the **Header value** to `Api-Token <YOUR-ACCESS-TOKEN>` , replace the placeholder `<YOUR-ACCESS-TOKEN>` with the generated access token
   
   - **Trigger** - select :
     - Merge request events
     - Job events
     - Pipeline events
    
5.  Click **Add webhook** to save the webhook.

### 3. Work with GitLab and observe organization-wide activities in Dashboards

1. In GitLab, let your developers create merge requests and execute pipelines. Each interaction will be sent to Dynatrace. 
2. In Dynatrace, navigate to **Dashboards**.
3. Open the **GitLab Pull Request** Dashboard to observe real-time activities of merge requests in your organization or seleced repositories.
4. Open the **GitLab Pipeline** Dashboard to observe and analyze pipeline execution details, job insights, and step durations for all GitLab pipelines in your organization or selected repositories.

## Call to action

We highly value your insights on GitLab pipeline observability. Your feedback is crucial in helping us enhance our tools and services. Please visit the Dynatrace Community page to share your experiences, suggestions, and ideas. Your contributions are instrumental in shaping the future of our platform. Join the discussion today and make a difference! 

## Further reading

**Pipeline Observability**

* [Observability throughout the software development lifecycle increases delivery performance](https://www.dynatrace.com/news/blog/observability-throughout-the-software-development-lifecycle/) (blog post)
* [Concepts](https://docs.dynatrace.com/docs/deliver/pipeline-observability-sdlc-events/pipeline-observability-concepts) (docs)

**Software Development Lifecycle Events**
* [Ingest SDLC events](https://docs.dynatrace.com/docs/deliver/pipeline-observability-sdlc-events/sdlc-events) (docs)
* [SDLC event specification](https://docs.dynatrace.com/docs/discover-dynatrace/references/semantic-dictionary/model/sdlc-events) (docs)

## FAQ

* What are Software Development Lifecycle (SDLC) events?
  * SDLC events are events with a separate event kind in Dynatrace that follow a well-defined semantic for capturing data points from a software component's software development lifecycle. The [SDLC event specification](https://docs.dynatrace.com/docs/discover-dynatrace/references/semantic-dictionary/model/sdlc-events) defines the semantics of those events and will be extended based on the covered use cases. 

* Why have GitLab webhook events been changed into SDLC events?  
  * The main benefit is data normalization and the ability to become tool agnostic. As a result, Dynatrace Dashboards, Apps, and Automation can build on SDLC events with well-defined properties rather than tool-specific details. 

* Why going with GitLab webhooks instead of REST API?
  * Using webhooks has the following advantages over using the API: (1) Webhooks require less effort and less resources than polling an API. (2) Webhooks scale better than API calls. (3) Webhooks allow near real-time updates, since webhooks are triggered when an event happens. See [Choosing webhooks or the REST API](https://docs.github.com/en/webhooks/about-webhooks#choosing-webhooks-or-the-rest-api) for more details.
