# Dynatrace Service Level Objectives

This example shows how [Dynatrace Service Level Objectives] can be configured and managed using Monaco.

The example provides the `service-lebel-objectives` project with three configurations. First, the `custom-sli` configuration, second, the `sli-reference` configuration, and third, the `custom-sli-with-segments` configuration.\


## Requirements

- Monaco `v2.22.0+`
- Dynatrace Platform environment
- OAuth credentials as described [here][OAuth credentials], including the additional scopes: `slo:slos:read` and `slo:slos:write`.


## Monaco commands

### Creating the configuration

```shell
monaco deploy manifest.yaml
```

### Delete the created configuration

```shell
monaco delete -m manifest.yaml
```

[Dynatrace Service Level Objectives]: https://docs.dynatrace.com/docs/deliver/service-level-objectives
[OAuth credentials]: https://www.dynatrace.com/support/help/manage/configuration-as-code/guides/create-oauth-client#create-an-oauth-client