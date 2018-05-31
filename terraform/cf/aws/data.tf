data "aws_nat_gateway" "selected" {
  id = "${var.nat_id}"
}
