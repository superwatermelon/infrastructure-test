/*
 * A Swarm cluster with a single Manager.
 */

module "swarm_manager" {
  source = "./modules/swarm-manager"

  instance_type     = "${var.swarm_manager_instance_type}"
  key_name          = "${var.swarm_manager_key_pair}"
  subnet_id         = "${aws_subnet.data.0.id}"
  availability_zone = "${aws_subnet.data.0.availability_zone}"

  vpc_security_group_ids = [
    "${aws_security_group.swarm_manager_sg.id}",
    "${aws_security_group.swarm_node_sg.id}",
    "${aws_security_group.users_sg.id}"
  ]
}
