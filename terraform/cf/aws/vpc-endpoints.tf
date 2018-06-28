resource "aws_vpc_endpoint" "cf_rds_kms" {
  vpc_id            = "${var.vpc_id}"
  service_name      = "com.amazonaws.${var.region}.kms"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    "${aws_security_group.cf_rds.id}"
  ]

  private_dns_enabled = true
  subnet_ids          = ["${aws_subnet.rds_az1.id}", "${aws_subnet.rds_az2.id}", "${aws_subnet.rds_az3.id}"]
}
