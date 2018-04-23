resource "aws_elb" "concourse" {
  name            = "${var.environment}-concourse-elb"
  subnets         = ["${aws_subnet.default.id}"]
  security_groups = ["${aws_security_group.elb.id}"]

  listener {
    instance_port      = 8080
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "${aws_acm_certificate.concourse.arn}"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8080/"
    interval            = 6
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    Name = "${var.environment}"
  }
}

resource "aws_security_group" "elb" {
  name        = "${var.environment}_concourse_public_elb_security_group"
  description = "Concourse public access"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name = "${var.environment}"
  }
}

resource "aws_security_group_rule" "concourse_elb_https" {
  security_group_id = "${aws_security_group.elb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "concourse_elb_to_web" {
  security_group_id        = "${aws_security_group.elb.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 8080
  to_port                  = 8080
  source_security_group_id = "${aws_security_group.default.id}"
}
