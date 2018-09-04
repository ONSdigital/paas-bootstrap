variable "concourse_ip" {
  default = "10.0.1.10"
}

variable "default_gw_ip" {
  default = "10.0.1.1"
}

variable "default_route_table_id" {}
variable "vpc_id" {}
variable "environment" {}

variable "region" {
  default = "eu-west-1"
}

variable "az1" {
  default = "eu-west-1a"
}

variable "az2" {
  default = "eu-west-1b"
}

variable "az3" {
  default = "eu-west-1c"
}

variable "public_key" {}
variable "parent_dns_zone" {}

variable "private_dns_zone" {}

variable "ingress_whitelist" {
  "type" = "list"
}

variable "s3_kms_key_id" {}
variable "s3_kms_key_arn" {}
variable "state_bucket_id" {}

variable "s3_prefix" {}

variable "vpc_dns_nameserver" {}