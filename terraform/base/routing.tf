resource "aws_eip" "nat" {
  count = "${local.num_azs}"
  vpc = true

  tags {
    Name        = "${var.environment}-nat-gateway-az${count.index+1}-eip"
    Environment = "${var.environment}"
  }
}

resource "aws_nat_gateway" "nat" {
  count = "${local.num_azs}"
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"

  tags {
    Name        = "${var.environment}-az${count.index+1}-nat"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table" "az" {
  count = "${local.num_azs}"
  vpc_id = "${aws_vpc.default.id}"

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name        = "${var.environment}-az${count.index+1}-route-table"
    Environment = "${var.environment}"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

resource "aws_route" "nat" {
  count = "${local.num_azs}"
  route_table_id         = "${element(aws_route_table.az.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.nat.*.id, count.index)}"
}

resource "aws_route_table_association" "internal" {
  count = "${local.num_azs}"
  subnet_id      = "${element(aws_subnet.internal.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.az.*.id, count.index)}"
}

resource "aws_route_table_association" "services" {
  count = "${local.num_azs}"
  subnet_id      = "${element(aws_subnet.services.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.az.*.id, count.index)}"
}

resource "aws_route_table_association" "prometheus" {
  count = "${local.num_azs}"
  subnet_id      = "${element(aws_subnet.prometheus.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.az.*.id, count.index)}"
}