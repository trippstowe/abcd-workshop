# This is the token to communicate with the Fastly API. This was provisioned in
# advance and can be found at terraform/terraform.tfvars.
variable "fastly_api_token" {
  type = "string"
}

# This is a unique value for your service in the class. This was provisioned in
# advance and can be found at terraform/terraform.tfvars.
variable "fastly_name" {
  type = "string"
}
variable "fastly_domain"{}
variable "fastly_backend_bucket"{}

provider "fastly" {
  api_key = "${var.fastly_api_token}"
}

resource "fastly_service_v1" "my-fastly-service" {
  name = "${var.fastly_name}"

  force_destroy = true

  domain {
    name    = "${var.fastly_domain}"
    comment = "Altitude 2017 workshop domain"
  }

  backend {
    address               = "storage.googleapis.com"
    ssl_hostname          = "${var.fastly_backend_bucket}.storage.googleapis.com"
    name                  = "${var.fastly_backend_bucket}"
    port                  = 443
    first_byte_timeout    = 3000
    max_conn              = 200
    between_bytes_timeout = 1000
  }

  header {
    name        = "backend-host-override"
    action      = "set"
    type        = "request"
    destination = "http.Host"
    source      = "\"${var.fastly_backend_bucket}.storage.googleapis.com\""
  }
}

output "address" {
  value = "${var.fastly_name}.${var.fastly_domain}/index.html"
}
