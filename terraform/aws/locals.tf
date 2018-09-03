locals {
  num_azs = "${length(var.availability_zones)}"
  public_subnet_offset = 1
  internal_subnet_offset = "${local.public_subnet_offset + local.num_azs}"
  services_subnet_offset = "${local.internal_subnet_offset + local.num_azs}"
}