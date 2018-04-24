variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}

variable "region" {
  default = "eu-west-1"
}

variable "environment" {}

variable "az" {
  default = "eu-west-1a"
}

variable "ingress_whitelist" {
  default = ["0.0.0.0/0"]
}
