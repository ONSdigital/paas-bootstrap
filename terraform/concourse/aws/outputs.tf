output "default_security_groups" {
    value = ["${aws_security_group.default.id}"]
}

output "internal_cidr" {
    value = "${aws_subnet.default.cidr_block}"
}

output "internal_gw" {
    value = "${var.default_gw_ip}"
}

output "internal_ip" {
    value = "${var.concourse_ip}"
}

output "public_ip" {
    value = "${aws_eip.atc.public_ip}"
}

output "subnet_id" {
    value = "${aws_subnet.default.id}"
}

output "az" {
    value = "${var.az}"
}

output "region" {
    value = "${var.region}"
}

output "default_key_name" {
    value = "${aws_key_pair.default.key_name}"
}