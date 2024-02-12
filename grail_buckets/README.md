# Grail Bucket definitions

This is a simple example of how to configure and use [custom Grail buckets](https://www.dynatrace.com/support/help/platform/grail/data-model#custom-grail-buckets)
using Monaco.

It will create a new custom bucket and a rule to route specific logs to the new bucket.

## Prerequisites

- Monaco >=`v2.9.0`
- Dynatrace Platform environment
- OAuth client as described [here](https://www.dynatrace.com/support/help/manage/configuration-as-code/guides/create-oauth-client#create-an-oauth-client).

## Environment variables

You need a Dynatrace Platform environment and the following environment variables to try this out:

* `DT_ENV_ID`: <YOUR-DT-ENVIRONMENT-ID>
* `DT_ENV_URL`: https://<YOUR-DT-ENVIRONMENT-ID>.apps.dynatrace.com
* `API_TOKEN`: Create a token as described [here](https://www.dynatrace.com/support/help/manage/configuration-as-code/manage-configuration#prerequisites)
* `CLIENT_ID`: *Returned when creating the OAuth client*
* `CLIENT_SECRET`: *Returned when creating the OAuth client* 