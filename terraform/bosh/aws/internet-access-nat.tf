resource "aws_route_table" "az1" {
  vpc_id = "${var.vpc_id}"

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name        = "${var.environment}-nat-az1"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table_association" "az1" {
  subnet_id      = "${aws_subnet.az1.id}"
  route_table_id = "${aws_route_table.az1.id}"
}

resource "aws_security_group_rule" "allow-all" {
  security_group_id = "${aws_security_group.bosh.id}"
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_route" "nat" {
  route_table_id         = "${aws_route_table.az1.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${var.nat_az1_id}"
}
