data "aws_route53_zone" "parent" {
  name = "${var.parent_dns_zone}."
}

data "aws_route53_zone" "child_zone" {
  name = "${var.environment}.${var.parent_dns_zone}."
}

resource "aws_route53_record" "prometheus_direct" {
  zone_id = "${data.aws_route53_zone.child_zone.zone_id}"
  name    = "prometheus.${var.environment}.${data.aws_route53_zone.parent.name}"
  type    = "A"
  ttl     = "30"

  records = ["${aws_eip.prometheus.public_ip}"]
}
