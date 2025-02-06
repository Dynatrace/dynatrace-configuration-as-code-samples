# Observe your ArgoCD 

Enable Platform Engineering teams to analyze the efficiency of ArgoCD deployments to drive improvements and optimize the Internal Development Platform (IDP).

Observing ArgoCD sync activities is crucial for a platform engineer for several reasons:

* **Early Issue Detection**: By keeping an eye on sync activities, you can quickly identify and address issues such as failed deployments, configuration errors, or resource conflicts. This proactive approach minimizes downtime and maintains system stability.

* **Compliance and Auditing**: Monitoring sync activities provides a clear audit trail of changes and deployments. This is essential for compliance with industry regulations and internal policies, as it ensures that all changes are tracked and documented.

* **Performance Optimization**: Observing sync activities allows you to analyze deployment performance metrics, such as sync duration and resource utilization. This data can be used to optimize the deployment process and improve overall system performance.

* **Improved Collaboration**: Sync activity logs provide transparency and visibility into the deployment process, facilitating better communication and collaboration among team members. This ensures that everyone is aware of the current state and any ongoing issues.


## Target audience

This tutorial is intended for Platform Engineers managing the internal Development Platform (IDP), including ArgoCD for managing your GitOps-based deployments. 

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

4. Clone the [Dynatrace configuration as code sample](https://github.com/Dynatrace/dynatrace-configuration-as-code-samples) repository and go to `argocd_observability`.
```
git clone https://github.com/Dynatrace/dynatrace-configuration-as-code-samples.git
cd argocd_observability
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
monaco download
```

2. Merge the content of `download_<DATE>_<NUMBER>\project\openpipline\events.sdlc.json` into the file `events.sdlc.argocd.json`.

3. Run the following command to apply the provided configuration. 
```
monaco deploy manifest.yaml
```

### 2. Configure ArgoCD sending Notifications to Dynatrace

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
#### Configure ArgoCD Notifications

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
    - when: app.status.operationState.phase in ['Succeeded', 'Failed', 'Error'] and app.status.health.status in ['Healthy', 'Degraded']
      send: [dynatrace-webhook-template]
    - when: app.status.operationState.phase == 'Running' and app.status.health.status in ['Healthy', 'Degraded']
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

### 3. Update Application to trigger ArgoCD

Continue working developing your applications and trigger a deployment by changing manifests. ArgoCD will continuously monitors the Git repository for any changes in the configuration files. When changes are detected, ArgoCD automatically pulls the latest configuration and deploys it to the Kubernetes cluster. 
All sync operations will then be reported to Dynatrace.

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
