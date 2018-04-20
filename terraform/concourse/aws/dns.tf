data "aws_route53_zone" "parent" {
  name = "${var.parent_dns_zone}."
}

resource "aws_route53_zone" "child_zone" {
  name = "${var.environment}.${data.aws_route53_zone.parent.name}"

  tags {
    Name = "${var.environment}"
  }
}

resource "aws_route53_record" "child_ns" {
  zone_id = "${data.aws_route53_zone.parent.zone_id}"
  name    = "${var.environment}.${data.aws_route53_zone.parent.name}"
  type    = "NS"
  ttl     = "30"

  records = [
    "${aws_route53_zone.child_zone.name_servers.0}.",
    "${aws_route53_zone.child_zone.name_servers.1}.",
    "${aws_route53_zone.child_zone.name_servers.2}.",
    "${aws_route53_zone.child_zone.name_servers.3}.",
  ]
}

resource "aws_route53_record" "concourse" {
  zone_id = "${aws_route53_zone.child_zone.zone_id}"
  name    = "ci.${var.environment}.${data.aws_route53_zone.parent.name}"
  type    = "CNAME"
  ttl     = "30"

  records = ["${aws_elb.concourse.dns_name}"]
}
