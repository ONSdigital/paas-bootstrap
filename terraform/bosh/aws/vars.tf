variable "vpc_id" {}

variable "az1" {
  default = "eu-west-1a"
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
