data "aws_subnet_ids" "public" {
  vpc_id = "${var.vpc_id}"

  tags {
    Environment = "${var.environment}"
    Visibility  = "public"
  }
}
