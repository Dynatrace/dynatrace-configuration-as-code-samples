> **_Disclaimer:_** This script is not supported by Dynatrace. Please utilize github issues for any issues that arrise. We will try our best to get to your issues.

# Dynatrace CaC Toolkit

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
    token:
      name: API_TOKEN
```

## Usage
There are three directories: configure, setting and global.

Each directory will contain many sub-directories of monaco projects, which contain a folder with a config.yaml and object.json.

#### Global Service Anomaly Detection
1. Edit the global\anomalyDetection\serviceAnom\config.yaml file. 

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

3. Run the monaco command in the /project directory
```bash
monaco deploy manifest.yaml --project serviceAnom -e ENV_NAME
```

## Monaco V2 Templates Supported Setting/Configuration Projects

| Name | Type | Description | Group | Monaco Command |
| ------ | ------ | ------ | ------ | ------ |
| service | setting | individual services settings | anomalyDetection, generalFailureDetection, httpFailureDetection, keyRequests, mutedRequests | ```monaco deploy manifest.yaml --project service.GROUP -e ENV_NAME```|
| database | setting | individual database setting | N/A | ```monaco deploy manifest.yaml --project database -e ENV_NAME``` |
| databaseServiceAnom | global | global database setting | N/A | ```monaco deploy manifest.yaml --project databaseServiceAnom -e ENV_NAME``` |
| serviceAnom | global | global service setting | N/A | ```monaco deploy manifest.yaml --project serviceAnom -e ENV_NAME``` |
| kubernetesAnom | global | global k8s setting | cluster, namespace, node, workload, presVolumeClaim | ```monaco deploy manifest.yaml --project kubernetesAnom.GROUP -e ENV_NAME``` |
| rumAnom | global | global rum setting | app, customApp, customAppCrash, mobile, mobileCrash | ```monaco deploy manifest.yaml --project rumAnom.GROUP -e ENV_NAME``` |
