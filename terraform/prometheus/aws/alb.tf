resource "aws_lb" "prometheus" {
  name                             = "${var.environment}-prometheus-alb"
  subnets                          = ["${data.aws_subnet_ids.public.ids}"]
  security_groups                  = ["${aws_security_group.prometheus_alb.id}"]
  load_balancer_type               = "application"
  internal                         = false
  enable_cross_zone_load_balancing = true

  tags {
    Name        = "${var.environment}-prometheus-alb"
    Environment = "${var.environment}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "prometheus_443" {
  depends_on        = ["aws_acm_certificate_validation.prometheus"]
  load_balancer_arn = "${aws_lb.prometheus.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${aws_acm_certificate.prometheus.arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.grafana.arn}"
    type             = "forward"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "grafana" {
  name     = "${var.environment}-grafana-target-group"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  tags {
    Name        = "${var.environment}-grafana-target-group"
    Environment = "${var.environment}"
  }

  health_check {
    path                = "/"
    port                = 3000
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 5
  }

  lifecycle {
    create_before_destroy = true
  }
}
