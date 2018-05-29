resource "aws_eip" "nat" {
  vpc = true

  tags {
    Name        = "${var.environment}-nat-gateway-eip"
    Environment = "${var.environment}"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.az1.id}"

  tags {
    Name        = "${var.environment}-nat"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table" "az1" {
  vpc_id = "${var.vpc_id}"

  lifecycle {
    create_before_destroy = true
  }

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat.id}"
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
