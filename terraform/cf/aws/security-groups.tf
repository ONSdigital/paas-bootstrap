resource "aws_security_group" "cf-alb" {
  name        = "${var.environment}_cf_alb_security_group"
  description = "CF public access"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name        = "${var.environment}-cf-alb-security-group"
    Environment = "${var.environment}"
  }
}
