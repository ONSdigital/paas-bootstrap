data "aws_nat_gateway" "az1" {
  id = "${var.nat_az1_id}"
}

data "aws_nat_gateway" "az2" {
  id = "${var.nat_az2_id}"
}

data "aws_nat_gateway" "az3" {
  id = "${var.nat_az3_id}"
}

data "aws_subnet_ids" "public" {
  vpc_id = "${var.vpc_id}"

  tags {
    Environment = "${var.environment}"
    Visibility  = "public"
  }
}
