# Observe your ArgoCD syncs with Dashboards and normalized SDLC events through OpenPipeline

Excited to dive into your ArgoCD sync activities of your ArgoCD Applications? For this use case, you'll

* Integrate ArgoCD and Dynatrace.
* Use Dashboards to observe ArgoCD syncs.
* Use this information to optimize ArgoCD.

## Concepts

| Concept        | Description |
|------------|-----|
| Software Development Lifecycle (SDLC) events   | [SDLC events](https://docs.dynatrace.com/docs/deliver/pipeline-observability-sdlc-events/sdlc-events) are events with a separate event kind in Dynatrace that follow a well-defined semantic for capturing data points from a software component's software development lifecycle. The [SDLC event specification](https://docs.dynatrace.com/docs/discover-dynatrace/references/semantic-dictionary/model/sdlc-events) defines the semantics of those events. |
| Why were ArgoCD notifications changed into SDLC events? | The main benefit is data normalization and becoming tool agnostic. As a result, Dynatrace Dashboards, Apps, and Workflows can build on SDLC events with well-defined properties rather than tool-specific details. |

## Target audience

This tutorial is intended for Platform Engineers managing the internal Development Platform (IDP), including ArgoCD for managing your GitOps-based deployments. 

## What will you learn

In this tutorial, you'll learn how to

* Forward ArgoCD notifications to Dynatrace
* Normalize the ingested event data.
* Use Dashboards to analyze the data and derive improvements.

## Prerequisites

* [Install Dynatrace Configuration as Code via Monaco](https://docs.dynatrace.com/docs/deliver/configuration-as-code/monaco/installation)

## Setup

1. [Create an OAuth client](https://docs.dynatrace.com/docs/deliver/configuration-as-code/monaco/guides/create-oauth-client) with the following permissions.
    * Run apps: `app-engine:apps:run`
    * View OpenPipeline configurations: `openpipeline:configurations:read`
    * Edit OpenPipeline configurations: `openpipeline:configurations:write`
    * Create and edit documents: `document:documents:write`
    * View documents: `document:documents:read`

2. Store the retrieved client ID, secret, and token endpoint as separate environment variables.
    <!-- windows version -->
    Windows:
    ```
    $env:OAUTH_CLIENT_ID='<YOUR_CLIENT_ID>'
    $env:OAUTH_CLIENT_SECRET='<YOUR_CLIENT_SECRET>'
    $env:OAUTH_TOKEN_ENDPOINT='https://sso.dynatrace.com/sso/oauth2/token'
    ```
    <!-- linux / macOS version -->
    Linux / macOS:
    ```
    export OAUTH_CLIENT_ID='<YOUR_CLIENT_ID>'
    export OAUTH_CLIENT_SECRET='<YOUR_CLIENT_SECRET>'
    export OAUTH_TOKEN_ENDPOINT='https://sso.dynatrace.com/sso/oauth2/token'
    ```

3. Clone the [Dynatrace configuration as code sample](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples) repository and go to `argocd_observability`.
    ```
    git clone https://github.com/Dynatrace/dynatrace-configuration-as-code-samples.git
    cd dynatrace-configuration-as-code-samples/argocd_observability
    ```

4. Edit the `manifest.yaml` by exchanging the `<YOUR-DT-ENV-ID>` placeholder with your Dynatrace environment ID.
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

### Check the OpenPipeline configuration for SDLC events

> These steps modify the OpenPipeline configuration for SDLC events.
If your OpenPipeline configuration contains only default/built-in values, you can directly apply the Monaco configuration. If you have any custom ingest sources, dynamic routes, or pipelines, you'll first need to download your configuration and manually merge it into the Monaco configuration.

> Step 3 will indicate if a configuration merge is needed or if you can apply the provided configuration directly.

1. Go to **OpenPipeline** > **Events** > **Software development lifecycle**.
2.  Check the **Ingest sources**, **Dynamic routing**, and **Pipelines**.
    * Under **Ingest sources**, are there any other sources than **Endpoint for Software Development Lifecycle events**?
    * Under **Dynamic routing**, are there any other routes than **Default route**?
    * Under **Pipelines**, are there any other pipelines than **events.sdlc**?
3. If the answer to one of those questions is "yes", follow the steps below. Otherwise, skip ahead to step 4.
    * Download your OpenPipeline configuration
      ```
      monaco download -e <YOUR-DT-ENV-ID> --only-openpipeline
      ```
    * Open the following files:
      * Your downloaded configuration file, `download_<DATE>_<NUMBER>/project/openpipline/events.sdlc.json`.
      * The provided configuration file, `pipeline_observability/openpipline/events.sdlc.argocd.json`.
    * Merge the contents of events.sdlc.json into events.sdlc.argocd.json, and then save the file.
4. Apply the Monaco configuration.
  Run this command to apply the provided Monaco configuration.
  The configuration consists of (1) Dashboards to analyze ArgoCD activities and (2) OpenPipeline configuration to normalize [ArgoCD Notifications](https://argo-cd.readthedocs.io/en/stable/operator-manual/notifications/) into [SDLC events](pipeline-observability-ingest-sdlc-events).
    ```
    monaco deploy manifest.yaml
    ```

### Create a Dynatrace access token

An access token with *openpipeline scopes* is needed for Dynatrace to receive ArgoCD notifications processed by OpenPipeline. 

1. In Dynatrace, navigate to **Access Tokens**.
2. Click **Generate new token**.
3. Provide a descriptive name for your token.
4. Select the following scopes:
    * OpenPipeline - Ingest Software Development Lifecycle Events (Built-in)(`openpipeline.events_sdlc`)
    * OpenPipeline - Ingest Software Development Lifecycle Events (Custom)(`openpipeline.events_sdlc.custom`)
5. Click **Generate token**
6. Save the generated token securely for subsequent steps. It will be referred as `<YOUR-ACCESS-TOKEN>`.
​
### Configure ArgoCD Notifications

ArgoCD notifications are a feature of ArgoCD. These notifications provide a flexible way to alert users about important changes in the state of their applications managed by ArgoCD. Here's how they work:

* Triggers and Templates: You can configure triggers and templates to specify when notifications should be sent and what they should contain.
* Notification Channels: Notifications can be sent via various channels, including email, Slack, and webhooks. This ensures that users receive critical updates through their preferred communication platforms.
* Customizable: The system is highly configurable, allowing users to control which events trigger notifications and how these notifications are formatted and delivered.

For example, you can set up a notification to alert you when an application deployment succeeds or fails, helping you stay informed about the status of your deployments in real-time.

#### Create Notification Secret

1. Update the `argocd-notifications-secret` with:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: argocd-notifications-secret
stringData:
  dt-base-url: https://{your-environment-id}.live.dynatrace.com
  dt-access-token: <YOUR-ACCESS-TOKEN>
```

2. Apply configuration:
```
kubectl apply -f {secret_file_name}.yaml -n argocd
```

#### Create a Notification Template and Trigger

1. ​If you do not currently have any notification configuration, create a config map as follows:​
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-notifications-cm
data: 
  service.webhook.dynatrace-webhook: |
    url: $dt-base-url
    headers:
    - name: "Authorization"
      value: Api-Token $dt-access-token
    - name: "Content-Type"
      value: "application/json; charset=utf-8"

  template.dynatrace-webhook-template: |
    webhook:
      dynatrace-webhook:
        method: POST
        path: /platform/ingest/custom/events.sdlc/argocd
        body: |
            {
              "app": {{toJson .app}},
              "context": {{toJson .context}},
              "service_type": {{toJson .serviceType}},
              "recipient": {{toJson .recipient}},
              "commit_metadata": {{toJson (call .repo.GetCommitMetadata .app.status.operationState.syncResult.revision)}}
            }
  
  trigger.dynatrace-webhook-trigger: |
    - when: app.status.operationState.phase in ['Succeeded'] and app.status.health.status in ['Healthy', 'Degraded']
    - when: app.status.operationState.phase in ['Failed', 'Error']
      send: [dynatrace-webhook-template]
    - when: app.status.operationState.phase in ['Running'] 
      send: [dynatrace-webhook-template]

```
**Notes:**
* `dynatrace-webhook` is the name of the service, `$dt-access-token` is a reference to the Dynatrace access token, and `$dt-base-url` is a reference to the Dynatrace event ingest endpoint stored in the `argocd-notifications-secret secret`.
* `dynatrace-webhook-template` is the name of the template, and `dynatrace-webhook` is a reference to the service created above.
* `dynatrace-webhook-trigger` is the name of the trigger, and `dynatrace-webhook-template` is a reference to the template created above.

2. Apply configuration:
```
kubectl apply -f {config_map_file_name}.yaml -n argocd
```

If you already have a notification configuration, extend the current one by adding the template, trigger and service sections from the example above.

#### Subscribe Applications to Notifications

After the service, trigger, and template have been added to the config map, you can subscribe any of your ArgoCD applications to the integration. Modify the annotations of the ArgoCD application by either using the ArgoCD UI or modifying the application definition with the following annotations:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  annotations:
    notifications.argoproj.io/subscribe.dynatrace-webhook-trigger.dynatrace-webhook: ""
```

**Notes:**
* The notifications annotation `notifications.argoproj.io` subscribes the ArgoCD application to the notification setup created above.

## Unlock enhanced deployment insights with ArgoCD Dashboards

Now that you've successfully configured ArgoCD and Dynatrace, you can use Dashboards and SDLC events to observe your ArgoCD syncs.

### Analyze

In Dynatrace, open the **ArgoCD Lifecycle Dashboard** to:

* ...

| ArgoCD Sync overview: | ArgoCD Sync details: |
|------------|-----|
| ![image](images/pipeline_dashboard_pipeline_details.png) | ![image](images/pipeline_dashboard_job_details.png) |

### Optimize

Leverage those insights for the following improvement areas:

* **Improved Performance**: Optimizing syncs can reduce the time it takes to deploy changes, making your deployment process more efficient.
Efficient syncs can help in better utilization of resources, reducing the load on your infrastructure.

* **Enhanced Reliability**: By optimizing syncs, you can minimize the chances of errors during deployment, leading to more stable and reliable releases. Ensuring that syncs are optimized can help maintain consistency across different environments.

### Continuous improvements

Regularly review your ArgoCD sync and adjust configuration to ensure they are optimized for performance. 

In Dynatrace, adjust the timeframe of the **ArgoCD Lifecycle Dashboard** dashboards to monitor the long-term impact of your improvements.

## Call to action

We highly value your insights on ArgoCD pipeline observability. Your feedback is crucial in helping us enhance our tools and services. Visit the Dynatrace Community page to share your experiences, suggestions, and ideas directly on [Feedback channel for CI/CD Pipeline Observability](https://community.dynatrace.com/t5/Platform-Engineering/Feedback-channel-for-CI-CD-Pipeline-Observability/m-p/269193). 

## Further reading

**Pipeline Observability**

* [Observability throughout the software development lifecycle increases delivery performance](https://www.dynatrace.com/news/blog/observability-throughout-the-software-development-lifecycle/) (blog post)
* [Concepts](https://docs.dynatrace.com/docs/deliver/pipeline-observability-sdlc-events/pipeline-observability-concepts) (docs)

**Software Development Lifecycle Events**

* [Ingest SDLC events](https://docs.dynatrace.com/docs/deliver/pipeline-observability-sdlc-events/sdlc-events) (docs)
* [SDLC event specification](https://docs.dynatrace.com/docs/discover-dynatrace/references/semantic-dictionary/model/sdlc-events) (docs)