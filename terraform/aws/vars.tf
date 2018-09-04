variable "region" {}

variable "environment" {}

variable "parent_dns_zone" {}

variable "vpc_cidr_block" {}

variable "ingress_whitelist" {
  type    = "list"
  default = []
}

variable "availability_zones" {
  type = "list"
  default = []
}

variable "s3_prefix" {
  default = "ons-paas"
}

variable "cidr_blocks" {
  type = "map"
}