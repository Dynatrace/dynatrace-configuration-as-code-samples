# Dynatrace Segments

This example shows how [Dynatrace Segments] can be configured and managed using Monaco.

The example provides the `segments` project with two configurations. First, the `segment` configuration, and second, the `dashboard` configuration.\
The dashboard depends on the segment to automatically include the segment. The dashboard will get the ID `dashboard-with-segment`.

## Requirements

- Monaco `v2.19.0+`
- Dynatrace Platform environment
- OAuth credentials as described [here][OAuth credentials], including the additional scopes:  
  `storage:filter-segments:read`, `storage:filter-segments:write`, `storage:filter-segments:delete`.


## Monaco commands

### Creating the configuration

```shell
monaco deploy manifest.yaml
```

### Delete the created configuration

```shell
monaco delete -m manifest.yaml
```

[Dynatrace Segments]: https://docs.dynatrace.com/docs/manage/segments
[OAuth credentials]: https://www.dynatrace.com/support/help/manage/configuration-as-code/guides/create-oauth-client#create-an-oauth-client