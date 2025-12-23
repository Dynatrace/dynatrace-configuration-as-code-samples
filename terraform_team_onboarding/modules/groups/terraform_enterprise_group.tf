resource "dynatrace_iam_group" "terraform_enterprise_group" {
  name                       = "Terraform Enterprise"
  description                = "Group for service accounts to allow running Terraform"
  federated_attribute_values = [var.entra_id_map["App-Prod-Dynatrace-TerraformEnterprise"]]
}

resource "dynatrace_iam_policy_bindings_v2" "terraform_enterprise_bind" {
  group       = dynatrace_iam_group.terraform_enterprise_group.id
  environment = var.environments.production
  policy {
    id = var.policies.data_access
  }
  policy {
    id = var.policies.functional
  }
  policy {
    id = var.policies.additional_automation_tfe
  }
}

resource "dynatrace_iam_policy_bindings_v2" "terraform_enterprise_bind_nonprod" {
  group       = dynatrace_iam_group.terraform_enterprise_group.id
  environment = var.environments.nonproduction
  policy {
    id = var.policies.data_access
  }
  policy {
    id = var.policies.functional
  }
  policy {
    id = var.policies.additional_automation_tfe
  }
}

resource "dynatrace_iam_policy_bindings_v2" "terraform_enterprise_bind_sandbox" {
  group       = dynatrace_iam_group.terraform_enterprise_group.id
  environment = var.environments.sandbox
  policy {
    id = var.policies.data_access
  }
  policy {
    id = var.policies.functional
  }
  policy {
    id = var.policies.additional_automation_tfe
  }
}