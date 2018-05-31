data "aws_nat_gateway" "default" {
  id = "${var.nat_id}"
}
