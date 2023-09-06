#!/bin/zsh 
#  ^^ - change to SH if needed

#Customer inputs - Jira and Slack app connections
export JIRA_URL=""                      # Jira Connection url e.g. https://<url>.atlassian.net
export USER_EMAIL="" 
export JIRA_TOKEN=""                    # Jira token for connection
export SLACK_BOT_TOKEN=""               # Slack bot app token

#Customer input - Workflow json
export SLACK_CHANNEL=""                 # ID of the Slack channel notifications should go to
export JIRA_PROJECT=""                  # Jira Project ID
export JIRA_ISSUE_TYPE="" -             # Jira issue type in an ID format
export JIRA_TICKET_REPORTER=""          # Jira ticket reporter in an ID format
export JIRA_TRANSITION_STATUS=""        # Jira transition status in an ID format
export AZURE_TENANT_ID="" 
export BEARER_CLIENT_ID=""              # Payload for bearer token - client ID
export BEARER_SCOPE=""                  # Payload for bearer token - scope e.g. https%3A%2F%2Fmanagement.azure.com%2F.default
export BEARER_CLIENT_SECRET=""          # Payload for bearer token - client secret

#Dynatrace variables needed
export DT_URL=""                        # Add your Dynatrace Tenant URL - e.g. https://<tenantId>.apps.dynatrace.com/
export DT_API_TOKEN=""                  # Dynatrace API token - Check prerequisite here (https://www.dynatrace.com/support/help/shortlink/configuration-as-code-manage-configuration#prerequisites) to see which scopes are required
export DT_OAUTH_CLIENT_ID=""            # Check "Create OAuth token" page to do this - https://www.dynatrace.com/support/help/manage/configuration-as-code/guides/create-oauth-client 
export DT_OAUTH_CLIENT_SECRET=""        # Same as above

echo "$JIRA_URL"
echo "$USER_EMAIL"
echo "$JIRA_TOKEN"
echo "$SLACK_BOT_TOKEN"
echo "$SLACK_CHANNEL"
echo "$JIRA_PROJECT"
echo "$JIRA_ISSUE_TYPE"
echo "$JIRA_TICKET_REPORTER"
echo "$JIRA_TRANSITION_STATUS"
echo "$AZURE_TENANT_ID"
echo "$DT_URL"
echo "$DT_API_TOKEN"
echo "$DT_OAUTH_CLIENT_ID"
echo "$DT_OAUTH_CLIENT_SECRET"





