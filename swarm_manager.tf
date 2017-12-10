/*
 * A Swarm cluster with a single Manager.
 */

resource "aws_instance" "swarm_manager" {
  ami             = "${data.aws_ami.coreos.id}"
  instance_type   = "${var.swarm_manager_instance_type}"
  key_name        = "${var.swarm_manager_key_pair}"
  subnet_id       = "${aws_subnet.data.0.id}"
  user_data       = "${data.template_file.swarm_manager_ignition.rendered}"
  security_groups = [
    "${aws_security_group.swarm_manager_sg.id}",
    "${aws_security_group.swarm_node_sg.id}",
    "${aws_security_group.users_sg.id}"
  ]

  tags {
    Name = "swarm-manager"
  }
}

resource "aws_ebs_volume" "swarm_manager" {
  availability_zone = "${aws_subnet.data.0.availability_zone}"
  size = 10
  tags {
    Name = "swarm-manager"
  }
}

resource "aws_volume_attachment" "swarm_manager" {
  device_name = "/dev/xvdf"
  volume_id   = "${aws_ebs_volume.swarm_manager.id}"
  instance_id = "${aws_instance.swarm_manager.id}"
}
