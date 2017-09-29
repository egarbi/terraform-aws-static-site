// Gral variables
variable "domain" {}

variable "site_name" {}

variable "public_dns_zone" {}

variable "acm_certificate_arn" {
  default = ""
}

variable "ssl_cert" {
  default = ""
}

variable "error_response_code" {
  default = "404"
}

variable "error_response_pagepath" {
  default = "/404.html"
}
