variable "vpc_id" {}

variable "az1" {
  default = "eu-west-1a"
}

variable "az2" {
  default = "eu-west-1b"
}

variable "az3" {
  default = "eu-west-1c"
}

variable "region" {
  default = "eu-west-1"
}

variable "environment" {}

variable "ingress_whitelist" {
  "type" = "list"
}

variable "parent_dns_zone" {}

variable "bosh_security_group_id" {}
variable "jumpbox_security_group_id" {}

variable "s3_kms_key_id" {}
variable "s3_kms_key_arn" {}
variable "state_bucket_id" {}

variable "nat_az1_id" {}
variable "nat_az2_id" {}
variable "nat_az3_id" {}

variable "public_ip" {
  description = "Concourse public IP"
}

variable "s3_prefix" {}

variable "cf_rds_password" {}
variable "uaa_database_password" {}
variable "cc_database_password" {}
variable "bbs_database_password" {}
variable "routing_api_database_password" {}
variable "policy_server_database_password" {}
variable "silk_controller_database_password" {}
variable "locket_database_password" {}
