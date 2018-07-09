resource "aws_eip" "prometheus" {
  vpc = true

  tags {
    Name        = "${var.environment}-prometheus-eip"
    Environment = "${var.environment}"
  }
}
