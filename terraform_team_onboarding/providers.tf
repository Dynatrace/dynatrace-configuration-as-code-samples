terraform {
  required_providers {
    dynatrace = {
      version = ">= 1.85.0"
      source  = "dynatrace-oss/dynatrace"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">=3.3.0"
    }
  }
  cloud {
    organization = "dynatrace"
    hostname     = "terraform.com"
    workspaces {
      name = "dynatrace-config"
    }
  }
}

provider "azuread" {
  tenant_id     = "<tenant_id>"
  client_id     = "<client_id>"
  client_secret = var.azuread_dynatrace_client_secret
}
