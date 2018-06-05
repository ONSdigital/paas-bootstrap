resource "aws_eip" "nat_az1" {
  vpc = true

  tags {
    Name        = "${var.environment}-nat-gateway-az1-eip"
    Environment = "${var.environment}"
  }
}

resource "aws_eip" "nat_az2" {
  vpc = true

  tags {
    Name        = "${var.environment}-nat-gateway-az2-eip"
    Environment = "${var.environment}"
  }
}

resource "aws_eip" "nat_az3" {
  vpc = true

  tags {
    Name        = "${var.environment}-nat-gateway-az3-eip"
    Environment = "${var.environment}"
  }
}

resource "aws_nat_gateway" "nat_az1" {
  allocation_id = "${aws_eip.nat_az1.id}"
  subnet_id     = "${aws_subnet.az1.id}"

  tags {
    Name        = "${var.environment}-az1-nat"
    Environment = "${var.environment}"
  }
}

resource "aws_nat_gateway" "nat_az2" {
  allocation_id = "${aws_eip.nat_az2.id}"
  subnet_id     = "${aws_subnet.az2.id}"

  tags {
    Name        = "${var.environment}-az2-nat"
    Environment = "${var.environment}"
  }
}

resource "aws_nat_gateway" "nat_az3" {
  allocation_id = "${aws_eip.nat_az3.id}"
  subnet_id     = "${aws_subnet.az3.id}"

  tags {
    Name        = "${var.environment}-az3-nat"
    Environment = "${var.environment}"
  }
}
