resource "aws_ebs_volume" "registry" {
  availability_zone = "${var.availability_zone}"
  size              = "${var.registry_volume_size}"
  type              = "gp2"
  tags {
    Name = "${var.name}-${var.registry_volume_name}"
  }
}

resource "aws_volume_attachment" "registry" {
  device_name  = "/dev/${var.registry_volume_device}"
  volume_id    = "${aws_ebs_volume.registry.id}"
  instance_id  = "${aws_instance.manager.id}"
  skip_destroy = true
}
