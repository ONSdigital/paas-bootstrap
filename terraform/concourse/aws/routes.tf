resource "aws_internet_gateway" "default" {
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "${var.environment}"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = "${var.default_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}
