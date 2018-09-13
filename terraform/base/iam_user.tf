resource "aws_iam_user" "service_user" {
    name = "${var.environment}-service-user"
}

resource "aws_iam_user_policy" "service_user_policy" {
    name = "${var.environment}-service-user-policy"
    user = "${aws_iam_user.service_user.name}"

    policy = "${data.template_file.iam_policy.rendered}"
}

resource "aws_iam_access_key" "service_user" {
    user = "${aws_iam_user.service_user.name}"
}