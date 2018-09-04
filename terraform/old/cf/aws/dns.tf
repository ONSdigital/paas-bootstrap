data "aws_route53_zone" "parent" {
  name = "${var.parent_dns_zone}."
}

data "aws_route53_zone" "child_zone" {
  name = "${var.environment}.${var.parent_dns_zone}."
}

data "aws_route53_zone" "private" {
  name   = "${var.private_dns_zone}."
  vpc_id = "${var.vpc_id}"
}

resource "aws_route53_record" "cf_system" {
  zone_id = "${data.aws_route53_zone.child_zone.zone_id}"
  name    = "*.system.${var.environment}.${data.aws_route53_zone.parent.name}"
  type    = "CNAME"
  ttl     = "30"

  records = ["${aws_lb.cf.dns_name}"]
}

resource "aws_route53_record" "cf_apps" {
  zone_id = "${data.aws_route53_zone.child_zone.zone_id}"
  name    = "*.apps.${var.environment}.${data.aws_route53_zone.parent.name}"
  type    = "CNAME"
  ttl     = "30"

  records = ["${aws_lb.cf.dns_name}"]
}

resource "aws_route53_record" "cf_ssh" {
  zone_id = "${data.aws_route53_zone.child_zone.zone_id}"
  name    = "ssh.system.${var.environment}.${data.aws_route53_zone.parent.name}"
  type    = "CNAME"
  ttl     = "30"

  records = ["${aws_elb.cf-ssh-lb.dns_name}"]
}

resource "aws_route53_record" "cf_rds" {
  zone_id = "${data.aws_route53_zone.private.zone_id}"
  name    = "cf_rds.${data.aws_route53_zone.private.name}"
  type    = "CNAME"
  ttl     = "30"

  records = ["${aws_db_instance.cf_rds.address}"]
}
