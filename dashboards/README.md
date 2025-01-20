
# Dashboards

These are sample dashboards based on configuration as code for deployment. The dashboards are designed to be deployed via Monaco, a tool that allows for the management of Dynatrace configurations as code. This repository contains various dashboards that can be used to monitor and visualize different aspects of your Dynatrace environment.

## Prerequisites

- Monaco >`v2.15.0`
- Dynatrace Platform environment with Dashboards installed.
- OAuth client as described [here](https://www.dynatrace.com/support/help/manage/configuration-as-code/guides/create-oauth-client#create-an-oauth-client), including the additional scope: `document:documents:write, document:documents:read, document:documents:delete, document:trash.documents:delete`. This returns value for the environment variables `CLIENT_ID` and `CLIENT_SECRET` mentioned below. 

## Executive Service SLO Dashboard

The Executive Service SLO Dashboard is a comprehensive set of dashboards aimed at providing insights into the effectiveness of different Service Level Indicators (SLIs) and Service Level Objectives (SLOs) for a set of services. This set includes two main dashboards:

#### Prerequisites
- Replace the `DT_ENV_URL` in the config.yaml > executive-dashboard config.

1. **Executive Overview Dashboard**: This dashboard aggregates SLO calculations by application, offering a high-level view of the overall performance and reliability of your services. It helps executives and stakeholders quickly understand how well the services are meeting their defined objectives.
![Executive Dashboard](/dashboards/images/executive_sre_overview.png?raw=true)

2. **SLI Threshold Evaluation Dashboard**: This dashboard provides a more granular view of the SLO calculations, breaking down the performance and availability indicators for each service. It allows for a detailed analysis of how different SLI thresholds impact the overall SLO targets, helping teams identify areas for improvement and optimization.
![SLI Dashboard](/dashboards/images/sli_evaluator.png?raw=true)

By using these dashboards, you can effectively monitor and manage the performance and reliability of your services, ensuring that they meet the defined SLO targets and provide a high-quality experience for your users.

## Environment variables

You need a Dynatrace Platform environment and the following environment variables to try this out:

* `DT_ENV_ID`: <YOUR-DT-ENVIRONMENT-ID>
* `DT_ENV_URL`: https://<YOUR-DT-ENVIRONMENT-ID>.apps.dynatrace.com
* `API_TOKEN`: Create a token as described [here](https://www.dynatrace.com/support/help/manage/configuration-as-code/manage-configuration#prerequisites)
* `CLIENT_ID`: *Returned when creating the OAuth client*
* `CLIENT_SECRET`: *Returned when creating the OAuth client* 

