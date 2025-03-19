# Service Level Objective Hub

This is a hub of SLOs templates to be simplify the rollout of standardized SLOs via configuration as code.

## Prerequisites

- Monaco >`v2.22.0`
- Dynatrace Platform environment with SLOs installed.
- OAuth client as described [here](https://www.dynatrace.com/support/help/manage/configuration-as-code/guides/create-oauth-client#create-an-oauth-client), including the additional scope: `slo:slos:read, slo:slos:write, slo:objective-templates:read`. This returns value for the environment variables `CLIENT_ID` and `CLIENT_SECRET` mentioned below.

## Supported SLI Types:

| Type               | Objective                    |
| ------------------ | ---------------------------- |
| Service            | Availability, Performance    |
| Kubernetes Cluster | CPU, Memory Usage Efficiency |
| Http               | Availability, Performance    |
| Monitor            | Availability, Performance    |

![SLOs](/service-level-objective-hub/images/slos.png?raw=true)

## Environment variables

You need a Dynatrace Platform environment and the following environment variables to try this out:

- `DT_ENV_ID`: <YOUR-DT-ENVIRONMENT-ID>
- `DT_ENV_URL`: https://<YOUR-DT-ENVIRONMENT-ID>.apps.dynatrace.com
- `API_TOKEN`: Create a token as described [here](https://www.dynatrace.com/support/help/manage/configuration-as-code/manage-configuration#prerequisites)
- `CLIENT_ID`: _Returned when creating the OAuth client_
- `CLIENT_SECRET`: _Returned when creating the OAuth client_
