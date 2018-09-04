# SG
resource "aws_security_group" "concourse" {
  name        = "${var.environment}_concourse_security_group"
  description = "Concourse public access"
  vpc_id      = "${aws_vpc.default.id}"

  tags {
    Name        = "${var.environment}-concourse-security-group"
    Environment = "${var.environment}"
  }
}