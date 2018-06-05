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

resource "aws_route_table" "az2" {
  vpc_id = "${var.vpc_id}"

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name        = "${var.environment}-nat-az2"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table" "az3" {
  vpc_id = "${var.vpc_id}"

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name        = "${var.environment}-nat-az3"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table_association" "az1" {
  subnet_id      = "${aws_subnet.az1.id}"
  route_table_id = "${aws_route_table.az1.id}"
}

resource "aws_route_table_association" "az2" {
  subnet_id      = "${aws_subnet.az2.id}"
  route_table_id = "${aws_route_table.az2.id}"
}

resource "aws_route_table_association" "az3" {
  subnet_id      = "${aws_subnet.az3.id}"
  route_table_id = "${aws_route_table.az3.id}"
}

resource "aws_route" "nat" {
  route_table_id         = "${aws_route_table.az1.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${var.nat_az1_id}"
}

resource "aws_route" "nat" {
  route_table_id         = "${aws_route_table.az2.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${var.nat_az2_id}"
}

resource "aws_route" "nat" {
  route_table_id         = "${aws_route_table.az3.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${var.nat_az3_id}"
}
