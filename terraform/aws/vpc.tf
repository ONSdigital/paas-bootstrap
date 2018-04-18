resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/8"

  tags {
    Name = "${var.environment_name}"
  }
}
