provider "template" {}

data "template_file" "iam_policy" {
  template = "${file("${path.module}/templates/iam_policy.json")}"
}
