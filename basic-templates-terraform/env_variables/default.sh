#!/bin/sh

# Install CLI and Terraform Provider - https://docs.dynatrace.com/docs/deliver/configuration-as-code/terraform/terraform-cli


# Env variables necessary to run Terraform
# Dynatrace API Token with Terraform permissions, check https://docs.dynatrace.com/docs/manage/configuration-as-code/terraform/teraform-basic-example#prerequisites
# Permissions needed:
# - Read configuration (ReadConfig)
# - Write configuration (WriteConfig)
# - Read settings (settings.read)
# - Write settings (settings.write)

# To create a token that works for all configurations, also include the following permissions.

# - Create and read synthetic monitors, locations, and nodes (ExternalSyntheticIntegration)
# - Capture request data (CaptureRequestData)
# - Read credential vault entries (credentialVault.read)
# - Write credential vault entries (credentialVault.write)
# - Read network zones (networkZones.read)
# - Write network zones (networkZones.write)

# Dynatrace variables needed
export TF_VAR_DYNATRACE_API_TOKEN=""              # Dynatrace API token - Check prerequisite here (https://docs.dynatrace.com/docs/deliver/configuration-as-code/terraform/teraform-basic-example#prerequisites) to see which scopes are required
export TF_VAR_DYNATRACE_ENV_URL=""                # Add your Dynatrace Tenant URL - e.g. https://<tenantId>.live.dynatrace.com/

# Env variables for the Terraform export utility
export TF_VAR_DYNATRACE_TARGET_FOLDER=""          # Set your target folder as per instructions here - https://docs.dynatrace.com/docs/deliver/configuration-as-code/terraform/guides/export-utility#export-guide

# Env variables for Management Zone configuration 
export TF_VAR_managementZoneName=""               # Add your Management Zone Name variable here

# Env variables for Auto Tag configuration
export TF_VAR_autoTagName=""                      # Add your Auto Tag Name variable here

# Env variables for Alerting Profile configuration
export TF_VAR_alertingProfileName=""              # Add your Alerting Profile Name variable here

# Env variables for Web Application configuration
export TF_VAR_webApplicationName=""               # Add your Web App name variable here. This is how your app will be named in the frontend page of Dynatrace.

# Env variables for Application Detection configuration
export TF_VAR_applicationDetectionPattern=""      # Add application detection pattern for the matcher(EQUALS) - what is the domain?
# Env variables for Session Replay configuration
export TF_VAR_sessionReplayEnabled=              # Add true or false for enabling Session Replay - bool value
export TF_VAR_sessionReplayPercentage=           # Add your percentage for sessions that you want to capture for Session Replay - integer value

# Env variables for Ownership configuration - https://docs.dynatrace.com/docs/deliver/ownership
export TF_VAR_ownershipContact=""                # Add your Ownership contact
export TF_VAR_ownershipConfigName=""             # Add your Ownership configuration name - Please keep it all lower case and if there is more than 1 word, they have to be separated with an underscore - e.g. "platform_engineers"

# Env variables for Email notification integration 
export TF_VAR_emailNotificationName=""           # Add your Email Notification integration name variable here

# Env variables for HTTP Monitor configuration
export TF_VAR_httpMonitorName=""                 # Add your HTTP Monitor configuration name
export TF_VAR_httpMonitorFrequency=              # Add your monitor frequency here - integer value
export TF_VAR_httpLocationId=""                  # Add your HTTP Monitor location ID - e.g. "GEOLOCATION-xxxxxxxxx"
export TF_VAR_httpMonitorUrl=""                  # Add your HTTP Monitor URL that you want to monitor

# Env variables for SLO configuration
export TF_VAR_sloMetricName=""                   # Add your service name in this specific format e.g. <application_name> - the underscore is important
export TF_VAR_releaseStage=""                    # Add your stage e.g. dev,int,prod
export TF_VAR_sloConfigName=""                   # Add your SLO Configuration name


# echo $TF_VAR_DYNATRACE_API_TOKEN
# echo $TF_VAR_DYNATRACE_ENV_URL
# echo $TF_VAR_DYNATRACE_TARGET_FOLDER
# echo $TF_VAR_managementZoneName
# echo $TF_VAR_autoTagName
# echo $TF_VAR_alertingProfileName
# echo $TF_VAR_webApplicationName
# echo $TF_VAR_sessionReplayEnabled
# echo $TF_VAR_sessionReplayPercentage
# echo $TF_VAR_ownershipContact
# echo $TF_VAR_emailNotificationName
# echo $TF_VAR_httpMonitorFrequency
# echo $TF_VAR_httpLocationId
# echo $TF_VAR_httpMonitorUrl
# echo $TF_VAR_sloMetricName
# echo $TF_VAR_releaseStage
# echo $TF_VAR_sloConfigName
