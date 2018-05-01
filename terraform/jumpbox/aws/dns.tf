data "aws_route53_zone" "parent" {
  name = "${var.parent_dns_zone}."
}

data "aws_route53_zone" "child_zone" {
  name = "${var.environment}.${var.parent_dns_zone}."
}

resource "aws_route53_record" "jumpbox_direct" {
  zone_id = "${data.aws_route53_zone.child_zone.zone_id}"
  name    = "jumpbox.${var.environment}.${data.aws_route53_zone.parent.name}"
  type    = "A"
  ttl     = "30"

  records = ["${aws_eip.jumpbox.public_ip}"]
}
