# Monaco Settings

This example shows how [Dynatrace Settings 2.0] can be configured and managed using Monaco.

Each project in this folder includes a different functionality to show its functionalities.

## Projects
* [basic-example](./basic-example): This project shows how a basic Settings 2.0 object can be managed using Dynatrace. 
* [first-last](./first-last): This project shows how [ordered settings objects][Dynatrace Settings 2.0 Ordered] can be defined to be at the very front or back of other settings.
  The example uses application detection settings to display the example.

## Requirements

- Monaco `v2.22.0+`
- Dynatrace Platform environment
- OAuth credentials as described [here][OAuth credentials], including the additional scopes: `settings:objects:read`, `settings:objects:write`, and `settings:schemas:read`.
- A [Dynatrace API Access Token] with the permissions `ReadConfig` and `WriteConfig`.

## Monaco commands

### Creating the configuration

```shell
monaco deploy manifest.yaml -p <project>
```


[Dynatrace Settings 2.0]: https://docs.dynatrace.com/docs/manage/settings-20
[Dynatrace Settings 2.0 Ordered]: https://docs.dynatrace.com/docs/shortlink/settings20-landing#order
[OAuth credentials]: https://www.dynatrace.com/support/help/manage/configuration-as-code/guides/create-oauth-client#create-an-oauth-client
[Dynatrace API Access Token]: https://docs.dynatrace.com/docs/discover-dynatrace/references/dynatrace-api/basics/dynatrace-api-authentication
