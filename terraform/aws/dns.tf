resource "aws_route53_zone" "child_zone" {
  name = "${var.environment}.${data.aws_route53_zone.parent.name}"

  tags {
    Name        = "${var.environment}-zone"
    Environment = "${var.environment}"
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

resource "aws_route53_zone" "private" {
  name       = "paas-private"
  comment    = "Private DNS zone for internal CF add-ons"
  vpc_id     = "${aws_vpc.default.id}"
  vpc_region = "${var.region}"

  tags {
    Name        = "${var.environment}-paas-private-zone"
    Environment = "${var.environment}"
  }
}