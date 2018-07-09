resource "aws_acm_certificate" "prometheus" {
  domain_name = "prometheus.${var.environment}.${var.parent_dns_zone}"

  subject_alternative_names = [
    "prometheus.${var.environment}.${var.parent_dns_zone}",
    "grafana.${var.environment}.${var.parent_dns_zone}",
  ]

  validation_method = "DNS"

  tags {
    Name        = "${var.environment}-prometheus-cert"
    Environment = "${var.environment}"
  }
}

resource "aws_route53_record" "prometheus_validation" {
  name    = "${aws_acm_certificate.prometheus.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.prometheus.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.child_zone.zone_id}"
  records = ["${aws_acm_certificate.prometheus.domain_validation_options.0.resource_record_value}"]
  ttl     = 30
}

resource "aws_acm_certificate_validation" "prometheus" {
  certificate_arn         = "${aws_acm_certificate.prometheus.arn}"
  validation_record_fqdns = ["${aws_route53_record.prometheus_validation.fqdn}"]
}
