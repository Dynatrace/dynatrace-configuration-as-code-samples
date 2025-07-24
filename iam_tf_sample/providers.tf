#region "Provider"

terraform {
    required_providers {
        dynatrace = {
            version = "1.81.0"
            source = "dynatrace-oss/dynatrace"
        }
    }

    backend "local" {
        path = "./terraform.tfstate"
    }
}

provider "dynatrace" {
    //alias = "prod"
    /*
    dt_env_url              = # will be set by the environment variable DYNATRACE_ENV_URL
    client_id               = # will be set by the environment variable DT_CLIENT_ID
    client_secret           = # will be set by the environment variable DT_CLIENT_SECRET
    */
    account_id              = var.DT_ACCOUNT_ID // you can inject this value via the environment variable TF_VAR_DT_ACCOUNT_ID
}

#endregion