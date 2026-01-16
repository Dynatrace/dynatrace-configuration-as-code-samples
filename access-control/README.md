# Access control for settings objects

This example shows how to manage [access control] for settings objects in Dynatrace using Monaco.

Managing the access of other users is done via the `allUsers` property.
This property can have the value `none`, `read`, or `write`, giving other users no access, read access or full access, respectively.

The example provides the `access-control` project with three configurations.
First, the `access-control-read` configuration, which gives all users read access to the specified settings object,
second, the `access-control-write` configuration, which gives all users full access to the specified settings object,
and third, the `access-control-none` configuration, which removes all access for other users to the specified settings object.

## Requirements

- Monaco `v2.23.0+`
- Dynatrace Platform environment
- An [OAuth client][OAuth credentials], with the scopes `settings:objects:read`, `settings:objects:write`, and `settings:schemas:read`.
- The targeted Settings 2.0 object must support owner-based access control, as indicated by its schema having `ownerBasedAccessControl` set to `true`.


## Monaco commands

### Creating the configuration

```shell
monaco deploy manifest.yaml
```

### Delete the created configuration

```shell
monaco delete -m manifest.yaml
```

[access control]: https://docs.dynatrace.com/docs/analyze-explore-automate/workflows/actions/access-control
[OAuth credentials]: https://docs.dynatrace.com/docs/deliver/configuration-as-code/monaco/guides/create-oauth-client#create-an-oauth-client
