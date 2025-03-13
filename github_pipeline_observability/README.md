# Observe your GitHub Pull Requests and Workflows with Dashboards and normalized SDLC events through OpenPipeline

Enable Platform Engineering teams to grasp and analyze the efficiency of GitHub workflows and processes bound to GitHub pull requests to drive improvements and optimize the Internal Development Platform (IDP). By better understanding the integration of GitHub into your development routines or delivery processes, you can set actions in the following directions:

* *Streamlining CI/CD Pipelines*: Observing workflow executions allows you to identify bottlenecks and inefficiencies in your CI/CD pipelines. This helps in optimizing build and deployment processes, leading to faster and more reliable releases.

* *Improving Developer Productivity*: Automated workflows reduce the manual effort required for repetitive tasks, such as running tests and checking coding standards. This allows developers to focus more on writing code and less on administrative tasks.

* *Data-Driven Insights*: Analyzing telemetry data from pull requests and workflows provides valuable insights into the development process. This data can be used to make informed decisions and continuously improve the development flows.

## Target audience

This article is intended for Platform Engineers managing the internal Development Platform (IDP), including GitHub for an entire organization.

While GitHub provides you *Insights* into [Actions Usage/Performance Metrics](https://docs.github.com/en/actions/administering-github-actions/viewing-github-actions-metrics) for workflow executions on the organization and repository level, the presented data can't be adjusted according to your development processes. Consequently, you would miss functionality to derive tailored insights specific to your internal development platform and directly relevant to your team's development environment.

In this tutorial, you will learn how to forward GitHub webhook events to Dynatrace, normalize the ingested event data, and use ready-made dashboards to analyze the data and derive improvements.

> **Security Disclaimer**: This tutorial involves the use of a Dynatrace access token in GitHub webhook configuration, which could be misused if accessed by unauthorized individuals. To mitigate this risk, please adhere to the following security best practices:
> * **Minimal Permissions**: Assign the least set of permissions necessary for the access token, as outlined in this tutorial.
> * **Access Control**: Limit the ability to configure webhooks in GitHub to a small group of authorized personnel.
> * **Token Security**: Never commit the access token to a Git repository.

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
cd dynatrace-configuration-as-code-samples/github_pipeline_observability
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

In this section, you will upload two Dashboards and configure the ingest endpoint for GitHub Webhooks in Dynatrace. Before you continue, please check your OpenPipeline configuration for *Software development lifecycle events*.

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
monaco download -e <YOUR-DT-ENV-ID> --only-openpipeline
```

2. Merge the content of `download_<DATE>_<NUMBER>/project/openpipline/events.sdlc.json` into the file `events.sdlc.github.json`.

3. Run the following command to apply the provided configuration. 
```
monaco deploy manifest.yaml
```

### 2. Configure GitHub to send Webhook events to Dynatrace

#### Create Dynatrace Access Token

An access token with *openpipeline scopes* is needed for Dynatrace to receive GitHub webhook events processed by OpenPipeline. 

1. In Dynatrace, navigate to **Access Tokens**.
2. Click **Generate new token**.
3. Provide a descriptive name for your token.
4. Select the following scopes:
   - `openpipeline.events_sdlc.custom` 
   - `openpipeline.events_sdlc`
5. Click **Generate token**
6. Save the generated token securely for subsequent steps. It will be referred as `<YOUR-ACCESS-TOKEN>`.
​
#### Configure GitHub Webhook

You can configure webhooks at either the organization level (affecting all repositories) or the repository level. 

1. In GitHub, select your organization or repository.
2. Go to **Settings** > **Webhooks**.
3. Click **Add webhook**.
4. Configure the following settings:
   - **Payload URL**: Please exchange the placeholders `<YOUR-DT-ENV-ID>` and `<YOUR-ACCESS-TOKEN>` with your Dynatrace environment ID and access token, respectively. 
     ```
     https://<YOUR-DT-ENV-ID>.live.dynatrace.com/platform/ingest/custom/events.sdlc/github?api-token=<YOUR-ACCESS-TOKEN>
     ```
   - **Content Type**: `application/json`
   - **Which events would you like to trigger this webhook?**: Select *Let me select individual events* and enable:
     - Pull requests
     - Workflow runs
     - Workflow jobs
     - (disable "Pushes")
5. Select **Active** to receive event details when the hook is triggered.
6. Click **Add webhook** to save the webhook.

### 3. Work with GitHub and observe organization-wide activities in Dashboards

1. In GitHub, let your developers create pull requests and execute workflows. Each interaction will be sent to Dynatrace. 
2. In Dynatrace, navigate to **Dashboards**.
3. Open the **GitHub Pull Request** Dashboard to observe real-time activities of pull requests in your organization or seleced repositories.
4. Open the **GitHub Workflow** Dashboard to observe and analyze workflow execution details, job insights, and step durations for all GitHub workflows in your organization or selected repositories.

## Call to action

We highly value your insights on GitHub pipeline observability. Your feedback is crucial in helping us enhance our tools and services. Please visit the Dynatrace Community page to share your experiences, suggestions, and ideas. Your contributions are instrumental in shaping the future of our platform. Join the discussion today and make a difference! 

## Further reading

**Pipeline Observability**
* [Observability throughout the software development lifecycle increases delivery performance](https://www.dynatrace.com/news/blog/observability-throughout-the-software-development-lifecycle/) (blog post)
* [Concepts](https://docs.dynatrace.com/docs/deliver/pipeline-observability-sdlc-events/pipeline-observability-concepts) (docs)

**Software Development Lifecycle Events**
* [Ingest SDLC events](https://docs.dynatrace.com/docs/deliver/pipeline-observability-sdlc-events/sdlc-events) (docs)
* [SDLC event specification]() (docs)

## FAQ

* What are Software Development Lifecycle (SDLC) events?
  * SDLC events are events with a separate event kind in Dynatrace that follow a well-defined semantic for capturing data points from a software component's software development lifecycle. The [SDLC event specification]() defines the semantics of those events and will be extended based on the covered use cases. 

* Why have GitHub webhook events been changed into SDLC events?  
  * The main benefit is data normalization and the ability to become tool agnostic. As a result, Dynatrace Dashboards, Apps, and Automation can build on SDLC events with well-defined properties rather than tool-specific details. 

* Why going with GitHub webhooks instead of REST API?
  * Using webhooks has the following advantages over using the API: (1) Webhooks require less effort and less resources than polling an API. (2) Webhooks scale better than API calls. (3) Webhooks allow near real-time updates, since webhooks are triggered when an event happens. See [Choosing webhooks or the REST API](https://docs.github.com/en/webhooks/about-webhooks#choosing-webhooks-or-the-rest-api) for more details.