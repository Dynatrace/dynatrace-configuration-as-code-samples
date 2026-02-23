terraform {
  required_providers {
    dynatrace = {
      version = "~> 1.86"
      source  = "dynatrace-oss/dynatrace"
    }
  }

  backend "local" {
    path = "./terraform.tfstate"
  }
}

# The following environment variables must be set
#
# * DYNATRACE_PLATFORM_TOKEN
#
# * DYNATRACE_ENV_URL
#     https://<YOUR-DT-ENV-ID>.apps.dynatrace.com
#     E.g. https://abc12345.apps.dynatrace.com
