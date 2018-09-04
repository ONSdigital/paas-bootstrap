data "aws_caller_identity" "current" {}

data "aws_route53_zone" "parent" {
  name = "${var.parent_dns_zone}."
}

