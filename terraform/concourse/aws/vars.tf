variable "concourse_ip" {
    default = "10.0.1.10"
}
variable "default_gw_ip" {
    default = "10.0.1.1"
}
variable "default_route_table_id" {}
variable "vpc_id" {}
variable "environment_name" {}
variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "eu-west-1"
}
variable "az" {
    default = "eu-west-1a"
}
variable "public_key" {}