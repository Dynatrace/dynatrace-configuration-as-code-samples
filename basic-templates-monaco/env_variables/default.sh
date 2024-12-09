#!/bin/sh

# Env variables necessary to run Monaco
# export DT_API_TOKEN=""                                          
# Dynatrace API Token with Monaco permissions, check https://www.dynatrace.com/support/help/shortlink/configuration-as-code-manage-configuration#prerequisites
# Permissions needed:
# - read settings, 
# - write settings,
# - read SLO, 
# - write SLO, 
# - access problem and event feed, metrics and topology, 
# - create and read synthetic monitors, locations and nodes, 
# - read configuration, 
# - write configuration

#Dynatrace variables needed
export DT_API_TOKEN=""
export DT_URL=""                                                # Add your Dynatrace Tenant URL - e.g. https://<tenantId>.apps.dynatrace.com/
# export DT_API_TOKEN=""                                          # Dynatrace API token - Check prerequisite here (https://www.dynatrace.com/support/help/shortlink/configuration-as-code-manage-configuration#prerequisites) to see which scopes are required
# export DT_OAUTH_CLIENT_ID=""                                    # Check "Create OAuth token" page to do this - https://www.dynatrace.com/support/help/manage/configuration-as-code/guides/create-oauth-client 
# export DT_OAUTH_CLIENT_SECRET=""                                # Same as above

# Env variables for the Management Zone configuration
export TAG_KEY=""                                               # Add your tag key - Think of this as your "project" or "application" tag keys
export SERVICE_TAG_VALUE=""                                     # Add your service/application/product name depending on what type of tag structure you have
export KUBERNETES_CLUSTER_NAME=""                               # Add K8s cluster name


# Env variables for Application configuration
export RUM_PERCENTAGE=""                                        # Add percentage for RUM capture
export REPLAY_ENABLED=""                                        # Add true or false for session replay
export REPLAY_PERCENTAGE=""                                     # Add percentage for user sessions to be captured by session replay

# Env variables for Application detection rule configuration
export MATCHER=""                                               # Add match type for the type of matcher for the URL or Domain e.g. DOMAIN_EQUALS
export APP_DETECTION_PATTERN=""                                 # Add application detection pattern for the matcher - what is the domain?

# Env variables for the Alerting profile configuration
# TBD

# Env variables for the Problem Notification configuration
export PROBLEM_NOTIFICATION_URL=""                              # Add custom webhook URL

# Env variables for the HTTP Monitor configuration
export SYNTHETIC_LOCATION=""                                    # Add your Synthetic Location
export HTTP_SYNTHETIC_URL=""                                    # Add your request endpoint
export HTTP_MONITOR_FREQUENCY=""                                # Add your monitor frequency

# Env variables for Ownership configuration
export OWNERSHIP_EMAIL=""                                       # Add your team email
export CHANNEL_URL=""                                           # Add your microsoft teams channel URL
export OWNERSHIP_TEAM_NAME=""                                   # Add your team name responsible for this service

#Env variables for Maintenance Window configuration
export DISABLE_SYNTHETIC_MONITOR_EXECUTION=""                   # Add true or false for disabling synthetic monitor execution during MW
export SCHEDULE_TYPE=""                                         # Add schedule type for MW e.g. once,daily,weekly,monthly - for testing we will use "WEEKLY"
export SCHEDULE_START_DATE=""                                   # Add schedule start date in this format e.g. "2023-10-09"
export SCHEDULE_END_DATE=""                                     # Add schedule end date in the same format as above e.g. "2023-10-31"
export SCHEDULE_START_TIME_OF_DAY=""                            # Add schedule start time of day e.g. 11:49:00
export SCHEDULE_END_TIME_OF_DAY=""                              # Add schedule end time of day in the same format as above

# Env variables for SLO configuration
export RELEASE_PRODUCT=""                                       # Add your service/application/product name depending on what type of tag structure you have
#export RELEASE_STAGE=""                                        # Add stage e.g. dev,int,val
export SLO_METRIC_NAME=""                                       # Add your service name in this specific format e.g. <application_name> - the underscore is important
