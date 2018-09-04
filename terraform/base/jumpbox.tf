# SG
resource "aws_security_group" "jumpbox" {
  name        = "${var.environment}_jumpbox_security_group"
  description = "Jumpbox security group"
  vpc_id      = "${aws_vpc.default.id}"

  tags {
    Name        = "${var.environment}-jumpbox-security-group"
    Environment = "${var.environment}"
  }
}
