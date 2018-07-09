data "aws_route53_zone" "parent" {
  name = "${var.parent_dns_zone}."
}

data "aws_route53_zone" "child_zone" {
  name = "${var.environment}.${var.parent_dns_zone}."
}

resource "aws_route53_record" "prometheus" {
  zone_id = "${data.aws_route53_zone.child_zone.zone_id}"
  name    = "prometheus.${var.environment}.${data.aws_route53_zone.parent.name}"
  type    = "A"
  ttl     = "30"

  records = ["${aws_eip.prometheus.public_ip}"]
}

resource "aws_route53_record" "grafana" {
  zone_id = "${data.aws_route53_zone.child_zone.zone_id}"
  name    = "grafana.${var.environment}.${data.aws_route53_zone.parent.name}"
  type    = "CNAME"
  ttl     = "30"

  records = ["${aws_route53_record.prometheus.name}"]
}
