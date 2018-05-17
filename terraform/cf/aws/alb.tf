resource "aws_lb" "cf" {
  name                             = "${var.environment}-cf-alb"
  subnets                          = ["${aws_subnet.az1.id}", "${aws_subnet.az2.id}", "${aws_subnet.az3.id}"]
  security_groups                  = ["${aws_security_group.alb.id}"]
  load_balancer_type               = "application"
  internal                         = false
  enable_cross_zone_load_balancing = true

  tags {
    Name        = "${var.environment}-cf-alb"
    Environment = "${var.environment}"
  }
}
