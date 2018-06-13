resource "aws_lb" "cf-ssh-lb" {
  name                             = "${var.environment}-cf-ssh-lb"
  internal                         = false
  load_balancer_type               = "network"
  subnets                          = ["${data.aws_subnet_ids.public.ids}"]
  internal                         = false
  enable_cross_zone_load_balancing = true

  tags {
    Name        = "${var.environment}-cf-ssh-lb"
    Environment = "${var.environment}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "cf-ssh" {
  load_balancer_arn = "${aws_lb.cf-ssh-lb.arn}"
  port              = "2222"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.cf-ssh-lb.arn}"
    type             = "forward"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "cf-ssh-lb" {
  name     = "${var.environment}-cf-ssh-lb"
  port     = 2222
  protocol = "TCP"
  vpc_id   = "${var.vpc_id}"

  tags {
    Name        = "${var.environment}-cf-ssh-lb"
    Environment = "${var.environment}"
  }
}