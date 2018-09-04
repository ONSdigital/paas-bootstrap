resource "aws_key_pair" "default" {
  key_name   = "${var.environment}_default_ssh_key"
  public_key = "${var.public_key}"
}
