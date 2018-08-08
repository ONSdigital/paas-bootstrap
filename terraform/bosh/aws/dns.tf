data "aws_route53_zone" "private" {
  name   = "${var.private_dns_zone}."
  vpc_id = "${var.vpc_id}"
}

resource "aws_route53_record" "bosh_rds" {
  zone_id = "${data.aws_route53_zone.private.zone_id}"
  name    = "bosh_rds.${data.aws_route53_zone.private.name}"
  type    = "CNAME"
  ttl     = "30"

  records = ["${aws_db_instance.bosh_rds.address}"]
}

resource "aws_route53_record" "bosh_director" {
  zone_id = "${data.aws_route53_zone.private.zone_id}"
  name    = "bosh_director.${data.aws_route53_zone.private.name}"
  type    = "A"
  ttl     = "30"

  records = ["${cidrhost(aws_subnet.az1.cidr_block, 6)}"]
}
