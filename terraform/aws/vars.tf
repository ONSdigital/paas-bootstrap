variable "region" {
  default = "eu-west-1"
}

variable "environment" {}

variable "parent_dns_zone" {}

variable "ingress_whitelist" {
  type    = "list"
  default = ["0.0.0.0/0"]
}

variable "az1" {
  default = "eu-west-1a"
}

variable "az2" {
  default = "eu-west-1b"
}

variable "s3_prefix" {
  default = "ons-paas"
}

variable "cf_rds_password" {}

variable "uaa_database_password" {}
variable "cc_database_password" {}
variable "bbs_database_password" {}
variable "routing_api_database_password" {}
variable "policy_server_database_password" {}
variable "silk_controller_database_password" {}
variable "locket_database_password" {}
