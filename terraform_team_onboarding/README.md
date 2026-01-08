# Onboarding teams and the applications they own

## High-level overview of access controls

| Role | Access description | Process to grant | Policies in use| 
| - | - | - | - |
| Default User | View all confidential data. This includes entities, metrics, spans, logs, and events. <br> Access to view all settings, but not edit any. <br> Create and share documents with others. | Granted to all users and specified contractors. <br> No process required for employees, and most contractors | [Data Access](./policy_definitions/data_access.pol), and [Functional](./policy_definitions/functional.pol) in all environments. <br> [Sandbox](./policy_definitions/sandbox.pol) in [our sandbox environment](https://<your_sandbox>.apps.dynatrace.com/). | 
| Standard User <br> [team scope] | Data access group. <br> View confidential restricted data for a given team. | Entra ID group owned by the team. A block must exist in [services-input.json](services-input.json) for this team to work | [Additional Data](./policy_definitions/additional_data.pol) restricted by a boundary |
|  Power User <br> [team scope] | Settings and advanced features group. <br> Configure monitoring settings for a given team. | Entra ID group owned by the team. A block must exist in [services-input.json](services-input.json) for this team to work | [Power User](./policy_definitions/poweruser.pol) restricted by a boundary. <br> [Unscoped Settings](./policy_definitions/unscoped_settings.pol) |

Further links:
- To review all policies in use refer to [policy_definitions](./policy_definitions/)
- To view all policies possible in Dynatrace refer to [IAM policy reference](https://docs.dynatrace.com/docs/manage/identity-access-management/permission-management/manage-user-permissions-policies/advanced/iam-policystatements)
- Team specific boundary is templated in [groups module](./modules/groups/groups.tf)

## Dynatrace groups, policies, and policy bindings

Dynatrace groups are created using Terraform, which is fed from an input file [services-input.json](services-input.json) which follows the format:

```
[
    {
        "team_name": "Engineering Collaboration",
        "apps": [
            {
                "security_context": "confrestricted_jira",
                "app_name": "jira"
            },
            {
                "security_context": "confrestricted_confluence",
                "app_name": "confluence"
            },
            {
                "security_context": "confrestricted_bamboo",
                "app_name": "bamboo"
            }
        ],
        "poweruser_group": "App-Prod-DT-Engineering-Collaboration-PUsr",
        "data_group": "App-Prod-DT-Engineering-Collaboration-SUsr"
    },
    ...
]

```
**Important!**

> Do not specify a `Function` (`f_`) in the input file that has been defined in the host group.
> <br> The team scoped boundary uses `startsWith` to ensure the file is easier to maintain as any access to any Function of the Application is automatically granted.
> <br> *Links: [Naming standards](<insert team link here>) / [Boundary](./modules/groups/groups.tf)*

### Schema
For a full schema refer to [naming standards](<insert team link here>).

- `team_name` is the name of the team, and is only used as an identifier and part of the unique name for each user group to be created - allowed characters: `free text`

- `apps` is a JSON array where each object is an application that is owned of the team. This should be updated when onboarding a new app for an already onboarded team.

- `apps[n]` is an object containing:
    - `security_context` used for data access as part of the `dynatrace_iam_policy_boundary`
    - `app_name` exactly equal to `application.name` used in `dynatrace_iam_policy_boundary` - allowed characters: `[a-z0-9]{3,80}`
    - Application in `security context` and `app_name` **must match** `application` (`a_`) used in host group

- `poweruser_group` (also known as the "PUsr" group) is the name of a group in Entra ID that must already exist

- `data_group` (also known as the "standard user group" or "SUsr" group) is the name of a group in Entra ID that must already exist