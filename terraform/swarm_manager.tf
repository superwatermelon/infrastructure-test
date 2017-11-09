/*
 * A Swarm cluster with a single Manager.
 */

variable "swarm_manager_key_pair" {
  description = "The name of the key pair to use for the Swarm Manager node"
}

variable "swarm_manager_instance_type" {
  description = "The AWS instance type to use for the Swarm Manager node"
  default     = "t2.micro"
}

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

output "swarm_manager_public_ip" {
  value = "${aws_instance.swarm_manager.public_ip}"
}
