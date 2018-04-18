output "default_security_groups" {
    value = ["${aws_security_group.default.id}"]
}

output "internal_cidr" {
    value = "${aws_subnet.default.cidr_block}"
}

output "internal_gw" {
    value = "${aws_internet_gateway.default.id}"
}

output "internal_ip" {
    value = "${var.concourse_ip}"
}

output "public_ip" {
    value = "${aws_eip.atc.id}"
}

output "subnet_id" {
    value = "${aws_subnet.default.id}"
}
