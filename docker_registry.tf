resource "aws_instance" "docker_registry" {
  ami             = "${data.aws_ami.coreos.id}"
  instance_type   = "${var.docker_registry_instance_type}"
  key_name        = "${var.docker_registry_key_pair}"
  subnet_id       = "${aws_subnet.data.0.id}"
  user_data       = "${data.template_file.docker_registry_ignition.rendered}"
  security_groups = [
    "${aws_security_group.docker_registry_sg.id}",
    "${aws_security_group.users_sg.id}"
  ]

  tags {
    Name = "docker-registry"
  }
}

data "template_file" "docker_registry_ignition" {
  template = "${file("${path.module}/templates/docker_registry_ignition.tpl")}"
  vars {
    docker_registry_service = "${jsonencode(data.template_file.docker_registry_service.rendered)}"
    var_lib_registry_mount  = "${jsonencode(data.template_file.var_lib_registry_mount.rendered)}"
    format_volume_service   = "${jsonencode(data.template_file.format_volume_service.rendered)}"
    format_volume_enabled   = "${var.docker_registry_format_data == true}"
  }
}

resource "aws_ebs_volume" "docker_registry" {
  availability_zone = "${aws_subnet.data.2.availability_zone}"
  size              = 10
  type              = "gp2"
  tags {
    Name = "docker-registry"
  }
}

resource "aws_volume_attachment" "docker_registry_storage_att" {
  device_name  = "/dev/${var.docker_registry_volume_device}"
  volume_id    = "${aws_ebs_volume.docker_registry.id}"
  instance_id  = "${aws_instance.docker_registry.id}"
  skip_destroy = true
}
