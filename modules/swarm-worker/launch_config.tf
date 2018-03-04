resource "aws_launch_configuration" "worker" {
  image_id        = "${module.coreos.ami}"
  instance_type   = "${var.instance_type}"
  key_name        = "${var.key_name}"
  name_prefix     = "${var.name_prefix}"
  user_data       = "${data.template_file.ignition.rendered}"

  security_groups = ["${var.security_groups}"]

  lifecycle {
    create_before_destroy = true
  }
}
