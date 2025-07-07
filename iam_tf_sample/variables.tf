variable "DT_ACCOUNT_ID"{
  type        = string
  description = "Dynatrace Account ID. Optionally, you can automatically inject the value by specifying the environment variable TF_VAR_ACCOUNT_ID"
}

variable "FILE_PREFIX"{
  type        = string
  description = "Use this to indicate that a file should be used for policy or boundary statements as well as segments definition, rather than inline"
  default     = "$file:"
}