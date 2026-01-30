# Using Terraform to run and use DQL

This repository details how you can utilize DQL as a `data` block within your Terraform to query the state of your Dynatrace environment and then act on that as code.

This is intended as a simple example to get started, which can be taken forward for your specific use cases.

# Getting Started


The DQL data source requires an oAuth or Platform token with the ability to read the data in grail you are trying to access - as described on on the [provider documentation](https://registry.terraform.io/providers/dynatrace-oss/dynatrace/latest/docs/data-sources/dql). Please read this fully to understand the permissions and considerations before using this sample.

The sample contains only one Terraform file, `host-group-log-rules.tf` which is detailed below.

# DQL Datasources
As the size of an environment grows the number of configuration changes that must be made against specific entities also grows. 

When making these changes we require the entity ID to reference to specific settings object to change. This is where we can use DQL ([Dynatrace Query Language](https://docs.dynatrace.com/docs/discover-dynatrace/platform/grail/dynatrace-query-language)) to fetch the right IDs.

The sample [host-group-log-rules.tf](host-group-log-rules.tf) shows how to query for host groups:

```
fetch dt.entity.host_group
| filter startsWith(entity.name, "a_team1")
```

The output of the data source needs to be processed into a json object - as a local variable.

```
hostGroups = jsondecode(data.dynatrace_dql.host_group_dql.records)
```

Then we can create the required resource using a for each

```
for_each = { for hg in local.hostGroups : hg.id => hg }
```

Use this as a pattern to deploy configurations and maintain their values as the number of objects to create these settings on changes.