output "prometheus_subnet_az1_cidr" {
  value = "${aws_subnet.az1.cidr_block}"
}

output "prometheus_subnet_az1_id" {
  value = "${aws_subnet.az1.id}"
}

output "prometheus_security_group_id" {
  value = "${aws_security_group.prometheus.id}"
}

output "grafana_target_group_name" {
  value = "${aws_lb_target_group.grafana.name}"
}

output "prometheus_target_group_name" {
  value = "${aws_lb_target_group.prometheus.name}"
}

output "grafana_fqdn" {
  value = "${aws_route53_record.grafana.name}"
}

output "prometheus_fqdn" {
  value = "${aws_route53_record.prometheus.fqdn}"
}

output "alertmanager_fqdn" {
  value = "${aws_route53_record.alertmanager.fqdn}"
}
