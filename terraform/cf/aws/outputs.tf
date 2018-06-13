output "cf-internal-subnet-az1-id" {
  value = "${aws_subnet.az1.id}"
}

output "cf-internal-subnet-az1-cidr" {
  value = "${aws_subnet.az1.cidr_block}"
}

output "cf-internal-security-group-id" {
  value = "${aws_security_group.internal.id}"
}

output "cf-router-target-group-name" {
  value = "${aws_lb_target_group.cf.name}"
}

output "cf-router-lb-internal-security-group-id" {
  value = "${aws_security_group.cf_router_lb_internal_security_group.id}"
}

output "cf-ssh-lb-security-group-id" {
  value = "${aws_security_group.cf_ssh_lb.id}"
}

output "cf-ssh-target-group-name" {
  value = "${aws_lb_target_group.cf-ssh-lb.name}"
}
