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

variable "az3" {
  default = "eu-west-1c"
}

variable "s3_prefix" {
  default = "ons-paas"
}

variable "availability_zones" {
  type = "list"
  default = []
}

variable "vpc_cidr_block" {}

variable "cidr_blocks" {
  type = "map"
}

