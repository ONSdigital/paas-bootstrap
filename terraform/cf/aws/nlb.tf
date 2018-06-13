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
