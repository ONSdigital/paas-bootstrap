resource "aws_subnet" "az1" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.az1}"

  tags {
    Name        = "${var.environment}-default-subnet"
    Environment = "${var.environment}"
  }
}

resource "aws_subnet" "az2" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.az2}"

  tags {
    Name        = "${var.environment}-az2-subnet"
    Environment = "${var.environment}"
  }
}
