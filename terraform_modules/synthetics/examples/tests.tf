// Create HTTP checks from a file
module "http_file" {
  source = "../http"
  application_tag = "test"
  input = "http-input.json"
}

// Create HTTP checks from an input variable
module "http_input" {
  source = "../http"
  application_tag = "test"
  input = local.http-input
}

// Create network checks from a file
module "nam_file" {
  source = "../nam"
  application_tag = "test"
  input = "nam-input.json"
}

// Create network checks from an input variable
module "nam_input" {
  source = "../nam"
  application_tag = "test"
  input = local.nam-input
}