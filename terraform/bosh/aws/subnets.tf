resource "aws_subnet" "az1" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.az1}"

  tags {
    Name        = "${var.environment}-bosh-subnet"
    Environment = "${var.environment}"
  }
}
