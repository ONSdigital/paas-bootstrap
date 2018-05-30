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
