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

variable "concourse_ip" {
  default = "10.0.1.10"
}

variable "jumpbox_ip" {
  default = "10.0.1.5"
}

variable "default_gw_ip" {
  default = "10.0.1.1"
}

variable "s3_kms_key_id" {}
variable "s3_kms_key_arn" {}
variable "state_bucket_id" {}

variable concourse_security_group_id {}
variable jumpbox_security_group_id {}

variable "nat_az1_id" {}

variable "private_dns_zone" {}
