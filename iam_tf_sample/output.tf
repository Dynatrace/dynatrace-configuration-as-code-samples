# Example output to see the result
/*
output "groups_with_policy_details" {
    value = local.bindings_with_details
}
output "default_policies" {
    value = data.dynatrace_iam_policy.default_policies
}
output "custom_policies" {
    value = dynatrace_iam_policy.custom
}
*/

/*
output "dynatrace_iam_policy_bindings_v2" {
    value = dynatrace_iam_policy_bindings_v2.binding
}


output "dynatrace_iam_policy_bindings_v2_account" {
    value = dynatrace_iam_policy_bindings_v2.binding_account
}
*/
/*
output "policy_names_defult" {
  value = data.dynatrace_iam_policy.default_policies
}

output "policy_names_custom" {
  value = dynatrace_iam_policy.custom
}
*/
/*
output "policy_names_custom" {
  value = [for policy in {for group in local.bindings_with_details : group.groupname => group if length([for policy in group.policies : policy if upper(lookup(policy, "levelType", "")) == "ACCOUNT"]) > 0 && length(group.policies) > 0} : policy]
}
*/