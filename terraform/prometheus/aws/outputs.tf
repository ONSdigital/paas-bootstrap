output "prometheus_external_ip" {
  value = "${aws_eip.prometheus.public_ip}"
}

output "prometheus_subnet_az1_cidr" {
  value = "${aws_subnet.az1.cidr_block}"
}

output "prometheus_subnet_az1_id" {
  value = "${aws_subnet.az1.id}"
}

output "prometheus_security_group_id" {
  value = "${aws_security_group.prometheus.id}"
}
