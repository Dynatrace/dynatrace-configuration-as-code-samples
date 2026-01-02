variable "input" {
  type = any
  description = "Input to create as a file path or json encoded string"
}

variable "location" {
  default = "Dublin"
  type = string
  description = "Name of location to execute the synthetic from (dt.entity.synthetic_location.entity.name)"
}

variable "application_tag" {
  type = string
  description = "Tag to be used in Synthetic naming and as tag with key Application"
}