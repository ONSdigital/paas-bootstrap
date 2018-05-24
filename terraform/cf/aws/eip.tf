resource "aws_eip" "nat" {
  count = 3
  vpc   = true

  tags {
    Name        = "${var.environment}-nat-gateway-eip"
    Environment = "${var.environment}"
  }
}
