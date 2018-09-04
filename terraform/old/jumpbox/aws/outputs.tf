output "jumpbox_security_group" {
  value = "${aws_security_group.jumpbox.name}"
}

output "jumpbox_security_group_id" {
  value = "${aws_security_group.jumpbox.id}"
}

output "jumpbox_external_ip" {
  value = "${aws_eip.jumpbox.public_ip}"
}
