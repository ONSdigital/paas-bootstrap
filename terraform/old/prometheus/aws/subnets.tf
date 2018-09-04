resource "aws_subnet" "az1" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "10.0.11.0/24"
  availability_zone = "${var.az1}"

  tags {
    Name        = "${var.environment}-prometheus-az1-subnet"
    Environment = "${var.environment}"
    Visibility  = "private"
  }
}