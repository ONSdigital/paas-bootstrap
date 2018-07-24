output "prometheus_external_ip" {
  value = "${aws_eip.prometheus.public_ip}"
}