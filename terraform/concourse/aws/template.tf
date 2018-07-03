provider "template" {}

data "template_file" "iam_policy" {
  template = "${file("${path.module}/templates/iam_policy.json")}"

  vars {
    s3_kms_key_arn         = "${var.s3_kms_key_arn}"
    default_s3_kms_key_arn = "${data.aws_kms_key.default_s3.arn}"
    environment            = "${var.environment}"
    hosted_zone_id         = "${data.aws_route53_zone.child_zone.zone_id}"
    parent_hosted_zone_id  = "${data.aws_route53_zone.parent.zone_id}"
    region                 = "${var.region}"
    account_id             = "${data.aws_caller_identity.current.account_id}"
    subnet_id              = "${aws_subnet.az1.id}"
    security_group_id      = "${aws_security_group.concourse.id}"
    vpc_id                 = "${var.vpc_id}"
    s3_prefix              = "${var.s3_prefix}"
    private_zone_id        = "${data.aws_route53_zone.private.zone_id}"
  }
}
