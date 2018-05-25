output "cf-internal-subnet-az1-id" {
  value = "${aws_subnet.az1.id}"
}

output "cf-internal-subnet-az1-cidr" {
  value = "${aws_subnet.az1.cidr_block}"
}

output "cf-internal-security-group-id" {
  value = "${aws_security_group.internal.id}"
}
