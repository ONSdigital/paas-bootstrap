resource "aws_acm_certificate" "concourse" {
  domain_name       = "ci.${var.environment}.${var.parent_dns_zone}"
  validation_method = "DNS"

  tags {
    Name        = "${var.environment}-ci-cert"
    Environment = "${var.environment}"
  }
}

resource "aws_route53_record" "concourse_validation" {
  name    = "${aws_acm_certificate.concourse.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.concourse.domain_validation_options.0.resource_record_type}"
  zone_id = "${aws_route53_zone.child_zone.zone_id}"
  records = ["${aws_acm_certificate.concourse.domain_validation_options.0.resource_record_value}"]
  ttl     = 30
}

resource "aws_acm_certificate_validation" "concourse" {
  certificate_arn         = "${aws_acm_certificate.concourse.arn}"
  validation_record_fqdns = ["${aws_route53_record.concourse_validation.fqdn}"]
}
