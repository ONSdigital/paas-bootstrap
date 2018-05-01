variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}

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
