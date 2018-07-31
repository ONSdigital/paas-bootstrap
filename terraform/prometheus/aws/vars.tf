variable "vpc_id" {}
variable "az1" {}
variable "region" {}
variable "environment" {}
variable "bosh_security_group_id" {}
variable "cf_internal_security_group_id" {}

variable "ingress_whitelist" {
  type = "list"
}

variable "parent_dns_zone" {}

variable "s3_kms_key_arn" {}
variable "state_bucket_id" {}

variable "jumpbox_security_group_id" {}
variable "nat_az1_id" {}
