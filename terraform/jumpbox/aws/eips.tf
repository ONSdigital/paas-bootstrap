resource "aws_eip" "jumpbox" {
  vpc = true

  tags {
    Name        = "${var.environment}-jumpbox-eip"
    Environment = "${var.environment}"
  }
}
