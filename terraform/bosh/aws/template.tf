data "template_file" "cloud_controller_policy" {
  template = "${file("${path.module}/templates/cloud_controller_policy.json")}"

  vars {
    environment = "${var.environment}"
  }
}
