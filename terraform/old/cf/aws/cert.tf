resource "aws_acm_certificate" "cf" {
  domain_name               = "${var.environment}.${var.parent_dns_zone}"
  validation_method         = "DNS"
  subject_alternative_names = ["*.system.${var.environment}.${var.parent_dns_zone}", "*.apps.${var.environment}.${var.parent_dns_zone}"]

  tags {
    Name        = "${var.environment}-cf-system-cert"
    Environment = "${var.environment}"
  }
}

resource "aws_route53_record" "cf_validation" {
  count = 3

  name    = "${lookup(aws_acm_certificate.cf.domain_validation_options[count.index], "resource_record_name")}"
  type    = "${lookup(aws_acm_certificate.cf.domain_validation_options[count.index], "resource_record_type")}"
  zone_id = "${data.aws_route53_zone.child_zone.zone_id}"
  records = ["${lookup(aws_acm_certificate.cf.domain_validation_options[count.index], "resource_record_value")}"]
  ttl     = 30
}

resource "aws_acm_certificate_validation" "cf" {
  certificate_arn         = "${aws_acm_certificate.cf.arn}"
  validation_record_fqdns = ["${aws_route53_record.cf_validation.*.fqdn}"]
}
