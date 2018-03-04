resource "aws_instance" "manager" {
  ami             = "${module.coreos.ami}"
  instance_type   = "${var.instance_type}"
  key_name        = "${var.key_name}"
  subnet_id       = "${var.subnet_id}"
  user_data       = "${data.template_file.ignition.rendered}"

  vpc_security_group_ids = ["${var.vpc_security_group_ids}"]

  tags {
    Name = "${var.name}"
  }
}
