# GitHub Pipeline Observability Package

To leverage the GitHub Pipeline Observability Package, two steps are required:
* Configure Dynatrace OpenPipeline and upload Dashboards
* Configure GitHub to send Webhook events to Dynatrace

## Configure Dynatrace OpenPipeline and upload Dashboards

### Prerequisites

1. [Install Dynatrace Configuration as Code via Monaco](https://docs.dynatrace.com/docs/deliver/configuration-as-code/monaco/installation)
2. [Create an API token](https://docs.dynatrace.com/docs/deliver/configuration-as-code/monaco/manage-configuration#prerequisites) and store as environment variable
```
$env:DT_ENV_TOKEN 
```

3. [Create an OAuth client](https://docs.dynatrace.com/docs/deliver/configuration-as-code/monaco/guides/create-oauth-client) with the following permissions and store as it as environment variables:
    * "Scopes"

```
$env:OAUTH_CLIENT_ID
$env:OAUTH_CLIENT_SECRET 
```

4. (Optional) Download this repository and go to `github_pipeline_observability`
```
git clone
cd github_pipeline_observability
```

5. Edit the `manifest.yaml` to configure your environment:
```
manifestVersion: 1.0
projects:
  - name: pipeline_observability
environmentGroups:
  - name: group
    environments:
      - name: <ENVIRONMENT-NAME>
        url:
          type: value
          value: <YOUR-DT-ENV>
        auth:
            token:
              name: DT_ENV_TOKEN
            oAuth:
              clientId:
                name: OAUTH_CLIENT_ID
              clientSecret:
                name: OAUTH_CLIENT_SECRET
              tokenEndpoint:
                type: environment
                value: OAUTH_TOKEN_ENDPOINT
```


### Apply Monaco configuration

#### OpenPipeline configuration for Software Development Lifecycle is empty

To configure Dynatrace for GitHub pipeline observability, a OpenPipeline and two Dashboards need to be configured. 
Run the following command to apply this configure. 

```
monaco deploy manifest.yaml
```

#### OpenPipeline configuration for Software Development Lifecycle is available

MERGE is needed

## Configure GitHub to send Webhook events to Dynatrace

#### Create Dynatrace Access Token

To allow Dynatrace receiving GitHub webhook events that are processed using OpenPipeline, an access token with *openpipeline scopes* is needed. 

1. In Dynatrace, navigate to **Access Tokens**.
2. Click **Generate new token**.
3. Provide a descriptive name for your token.
4. Select the following scopes:
   - `openpipeline.events_sdlc.custom` 
   - `openpipeline.events_sdlc`
5. Click **Generate token**
6. Save the generated token securely for subsequent steps. It will be referred as `YOUR-ACCESS-TOKEN`.
​
#### Configure GitHub Webhook

You can configure webhooks at either the organization level (affecting all repositories) or the repository level. Note that *Lead Time For Changes* calculations and monitoring will only include the repositories where webhooks are configured.

1. In GitHub, select your organization or repository.
2. Go to **Settings** > **Webhooks**.
3. Click **Add webhook**.
4. Configure the following settings:
   - **Payload URL**: 
     ```
     https://{your-environment-id}.live.dynatrace.com/platform/ingest/custom/events.sdlc/github?api-token={YOUR-ACCESS-TOKEN}
     ```
   - **Content Type**: `application/json`
   - **Which events would you like to trigger this webhook?**: Select *Let me select individual events* and enable:
     - Pull requests
     - Statuses
     - Workflow runs
     - Workflow jobs
     - (disable "Pushes")
5. Select **Active** to receive event details when the hook is triggered.
6. Click **Add webhook** to save the webhook.

