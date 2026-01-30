# Dynatrace IAM Team Based Onboarding Terraform Sample
This repository shows how to create policies, and groups based on input files - while integrating with Azure Entra ID for SAML.

# Getting started 

## Policies
Read through the policies that will be created, adjusting to your needs using the [IAM policy reference](https://docs.dynatrace.com/docs/manage/identity-access-management/permission-management/manage-user-permissions-policies/advanced/iam-policystatements). 

## Groups
Review the groups design, noting that `/modules/groups/groups.tf` creates the team specific resources by iterating over `/services-input.json`
Other groups in this module are groups that are not team specific.

Adjust by removing, or adding groups needed for your use cases.

## Main
Finally review `/main.tf` to see how the modules are integrated together, and how a `data` block is used to query Azure.

## Deploy
Update group references to match the groups you use in Azure, and export the environment variables required for [AzureAd Group Datasource](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group).

Next Export environment variables for the oAuth client following the [Dynatrace terraform provider documentation](https://registry.terraform.io/providers/dynatrace-oss/dynatrace/latest/docs).

You will now be ready to plan and apply.


## Repository Structure

#### modules/groups/
This module manages the creation and configuration of various user groups within Dynatrace. It includes Terraform files for different group types such as admin groups, automation users, default users, elevated access groups, and viewer-only groups. It also handles integration with external identity providers like Azure Entra ID.

#### modules/iam_policy/
This module defines and manages IAM policies for the groups. It includes configurations for core policies, additional policies, and outputs the policy details for use in group assignments.

### policy_definitions/
This directory holds the policy definition files in `.pol` format. These files define the specific permissions and access levels for different roles, including admin, data access, functional, power user, sandbox, and unscoped settings policies. They serve as input for the IAM policy module to create corresponding policies in Dynatrace.

# Contributing
Contributions are welcome! Please open issues or submit pull requests to help improve this repository. Suggestions for new patterns, bug fixes, or documentation improvements are appreciated.