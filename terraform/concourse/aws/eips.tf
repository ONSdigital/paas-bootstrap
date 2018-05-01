resource "aws_eip" "atc" {
  vpc = true

  tags {
    Name        = "${var.environment}-atc-eip"
    Environment = "${var.environment}"
  }
}
