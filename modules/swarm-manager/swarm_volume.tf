resource "aws_ebs_volume" "swarm" {
  availability_zone = "${var.availability_zone}"
  size              = "${var.swarm_volume_size}"
  type              = "gp2"
  tags {
    Name = "${var.name}-${var.swarm_volume_name}"
  }
}

resource "aws_volume_attachment" "swarm" {
  device_name  = "/dev/${var.swarm_volume_device}"
  volume_id    = "${aws_ebs_volume.swarm.id}"
  instance_id  = "${aws_instance.manager.id}"
  skip_destroy = true
}
