data "aws_nat_gateway" "az1" {
  id = "${var.nat_az1_id}"
}

data "aws_nat_gateway" "az2" {
  id = "${var.nat_az2_id}"
}

data "aws_nat_gateway" "az3" {
  id = "${var.nat_az3_id}"
}
