variable "DYNATRACE_API_TOKEN" {
  description = "Add your Dynatrace API token"
  type = string
}

variable "DYNATRACE_ENV_URL" {
  description = "Add your Dynatrace Tenant URL"
  type = string
}

variable "managementZoneName" {
  description = "Name of the management zone"
  type        = string
}

variable "autoTagName" {
  description = "Name of the auto tag"
  type        = string
}

variable "alertingProfileName" {
  description = "Name of the alerting profile"
  type        = string
}

variable "webApplicationName" {
  description = "Name of the web app"
  type        = string
}

variable "applicationDetectionPattern" {
  description = "Inser your app domain"
  type        = string
}

variable "sessionReplayEnabled" {
  description = "Select 'true' or 'false' for Session replay activation"
  type        = bool
}

variable "sessionReplayPercentage" {
  description = "Select percentage value for cost control"
  type        = number
}

variable "ownershipConfigName" {
  description = "Insert your configuration name"
  type        = string
}

variable "ownershipContact" {
  description = "Insert team email contact"
  type        = string
}

variable "emailNotificationName" {
  description = "Name of your email notification configuration"
  type        = string
}

variable "httpMonitorName" {
  description = "Input your HTTP Monitor configuration name"
  type        = string
}

variable "httpMonitorFrequency" {
  description = "Input your monitor frequency"
  type        = number
}

variable "httpLocationId" {
  description = "Input your monitor location ID"
  type        = string
}

variable "httpMonitorUrl" {
  description = "Input your monitor URL"
  type        = string
}

variable "sloMetricName" {
  description = "Input your SLO metric start name"
  type        = string
}

variable "releaseStage" {
  description = "Input your release stage"
  type        = string
}

variable "sloConfigName" {
  description = "Input your SLO config name in Dynatrace"
  type        = string
}