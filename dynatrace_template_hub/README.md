> **_Disclaimer:_** This script is not supported by Dynatrace. Please utilize github issues for any issues that arrise. We will try our best to get to your issues.

> **_Disclaimer:_** Supported monaco version: 2+

# Dynatrace Template Hub

This is a Dynatrace CaC project of monaco v2 templates for every configuration and setting in Dynatrace. 

## Pre-requisites 

1. Installing monaco

```bash
https://www.dynatrace.com/support/help/shortlink/configuration-as-code-installation
```

2. Create an API-Token with the following permissions
```
API v2 scopes
- Read entities
- Write entities
- Read settings
- Write settings
- Read SLO
- Write SLO

API v1 scopes
- Read configuration
- Write configuration
- Access problem and event feed, metrics, and topology
```

3. Set Environment Variables
```bash
 export API_TOKEN="API_TOKEN"
```
4. Edit manifest.yaml

Replace the placeholders in the environmentGroups:

> ENV_NAME
> ENV_ID
> API_TOKEN

```bash
environmentGroups:
- name: default
  environments:
  - name: ENV_NAME
    url:
      value: https://ENV_ID.live.dynatrace.com
    auth:
      token:
        name: API_TOKEN
```

## Usage
There are several directories which will contain monaco projects. The directory "global" will contain projects which can only be applied globally.

Each directory will contain many sub-directories of monaco projects, which contain a folder with a config.yaml and object.json.

#### Service Anomaly Detection
1. Edit the anomalyDetection\serviceAnom\config.yaml file. 

Replace the parameter values with your own values. 
```yaml
        resp:
          ###################
          ## resp - responseTime
          ## Fields:
          ## enabled - enabled
          ## mode - detectionMode - "auto","fixed"
          ## degMilli (both) - degradationMilliseconds 
          ## degPercent (auto) - degradationPercent
          ## degSlowestMilli (both) - slowestDegradationMilliseconds
          ## degSlowestPercent (auto) - slowestDegradationPercent
          ## reqPerMin (both) - requestsPerMinute
          ## abState (both) - minutesAbnormalState
          ## sens (fixed) - sensitivity - "low","medium","high"
          ##############
          type: value
          value:
            enabled: true
            mode: "auto"
            degMilli: 399
            degPercent: 10
            degSlowestMilli: 1000
            degSlowestPercent: 100
            reqPerMin: 15
            abState: 1
            sens: "low"
```
> Most Monaco v2 projects contain a "default" parameter. Which returns the setting/configuration back to defaults if set to true.

3. Run the monaco command
```bash
monaco deploy manifest.yaml --project serviceAnom -e ENV_NAME
```

#### Workflow of multiple configurations
There are several configurations where the id/name should be used as input to another configuration.

> ex: managementZone -> alertingProfile

1. Copy the folders alertingProfile and managementZone, add them to a *new project folder*.

2. Add the *new project folder name* under list of projects in manifest.yaml

```yaml
  projects:
  - name: {YOUR PROJECT NAME}
    type: grouping
    path: {YOUR PROJECT NAME}/
```

3. Edit the alertingProfile > config.yaml to make a reference to the id of one of the managementZone configs

```yaml
    ...
    parameters:
      managementZone:
        type: reference
        project: managementZone
        configType: builtin:management-zones
        configId: {YOUR CONFIG MZ ID}
        property: id
    ...
```

4. Run the monaco command in the /project directory
```bash
monaco deploy manifest.yaml --project {YOUR PROJECT NAME} -e ENV_NAME
```

## Monaco V2 Templates Supported Setting/Configuration Projects

#### mirrored global & local settings/configurations

> settings templates require a switch of the scope to adjust if it's applied globally or locally.

| Name | Type | Description | Group | Monaco Command |
| ------ | ------ | ------ | ------ | ------ |
| databaseServiceAnom | both | database setting | N/A | ```monaco deploy manifest.yaml --project databaseServiceAnom -e ENV_NAME``` |
| serviceAnom | both | service setting | N/A | ```monaco deploy manifest.yaml --project serviceAnom -e ENV_NAME``` |
| kubernetesAnom | both | k8s setting | cluster, namespace, node, workload, presVolumeClaim | ```monaco deploy manifest.yaml --project kubernetesAnom.GROUP -e ENV_NAME``` |
| rumAnom | both | web/mobile/custom setting | app, customApp, customAppCrash, mobile, mobileCrash | ```monaco deploy manifest.yaml --project rumAnom.GROUP -e ENV_NAME``` |

#### strictly global settings/configurations

> templates which can only be applied globally.

| Name | Type | Description | Group | Monaco Command |
| ------ | ------ | ------ | ------ | ------ |
| tag | global | auto-tagging | N/A | ```monaco deploy manifest.yaml --project tag -e ENV_NAME``` |
| managementZone | global | management | N/A | ```monaco deploy manifest.yaml --project managementZone -e ENV_NAME``` |
| ownership | global | ownership teams | N/A | ```monaco deploy manifest.yaml --project ownership -e ENV_NAME``` |
| alertingProfile | global | alerting profiles | N/A | ```monaco deploy manifest.yaml --project alertingProfile -e ENV_NAME``` |

#### strictly local settings/configurations

> templates which can only be applied locally.

| Name | Type | Description | Group | Monaco Command |
| ------ | ------ | ------ | ------ | ------ |
| service | setting | service settings | anomalyDetection, generalFailureDetection, httpFailureDetection, keyRequests, mutedRequests | ```monaco deploy manifest.yaml --project service.GROUP -e ENV_NAME```|
| browserMonitor | setting | browser monitor settings | singleStep, multiStep | ```monaco deploy manifest.yaml --project browserMonitor.GROUP -e ENV_NAME```|
| httpMonitor | setting | http monitor settings | singleRequest | ```monaco deploy manifest.yaml --project httpMonitor.GROUP -e ENV_NAME```|