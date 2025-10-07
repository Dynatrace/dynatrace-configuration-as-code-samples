# Configuring your Dynatrace Account with Monaco

This is a sample for configuring Dynatrace Account configuration using monaco. 

It is also a sample for setting up the required Policies and Groups to use Monaco to configure Grail Buckets and Automations
on a Dynatrace Platform environment. 

## What this sample contains

This sample contains a simple Account configuration, consisting of a [Group](./casc-admin/groups.yaml), [Policy](./casc-admin/policies.yaml), [Boundary](./casc-admin/boundaries.yaml), and [User](./casc-admin/users.yaml).

When deployed the configuration will create a new policy granting Grail Bucket Admin access, assign this policy to a new
Group - which also grants all the generally required permission for use with Configuration-as-Code, as well as Automation Admin
access to `simple` workflows, configured via boundaries, and assign a user to the new group. 

The sample also contains a [delete file](./delete.yaml) allowing you to remove the configurations if you don't need them anymore.

## Deploying the sample

**Pre-requisites**
* Monaco CLI version 2.11.0+
* An OAuth token granting Dynatrace Account access
* The following environment variables defined
  * ACCOUNT_UUID ... the UUID of your account
  * ACCOUNT_OAUTH_CLIENT_ID ... your oAuth client's ID
  * ACCOUNT_OAUTH_CLIENT_SECRET ... your oAuth client's secret

You will also need to fill the sample configuration with actual values for your environment ID and the user you will tie Config-as-Code admin oAuth clients to. 

You can do this either by manually replacing the following values:
* %YOUR_ENVIRONMENT_ID% in [groups.yaml](./casc-admin/groups.yaml)
* %YOUR_USER_EMAIL% in [users.yaml](./casc-admin/users.yaml) and [delete.yaml](delete.yaml)

Or by setting your desired values as environment variables `YOUR_ENVIRONMENT_ID` and `YOUR_USER_EMAIL` and running the [configure.sh](configure.sh) shell script. (Requires `sed` command line tool to be installed)

Then you can deploy your configurations using monaco

```sh
monaco account deploy -m manifest-account.yaml
```
