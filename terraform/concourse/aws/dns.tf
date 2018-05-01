data "aws_route53_zone" "parent" {
  name = "${var.parent_dns_zone}."
}

data "aws_route53_zone" "child_zone" {
  name = "${var.environment}.${var.parent_dns_zone}."
}

resource "aws_route53_record" "concourse" {
  zone_id = "${data.aws_route53_zone.child_zone.zone_id}"
  name    = "ci.${var.environment}.${data.aws_route53_zone.parent.name}"
  type    = "CNAME"
  ttl     = "30"

  records = ["${aws_lb.concourse.dns_name}"]
}

resource "aws_route53_record" "concourse_direct" {
  zone_id = "${data.aws_route53_zone.child_zone.zone_id}"
  name    = "concourse.${var.environment}.${data.aws_route53_zone.parent.name}"
  type    = "A"
  ttl     = "30"

  records = ["${aws_eip.atc.public_ip}"]
}
