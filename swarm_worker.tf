module "swarm_worker" {
  source = "./modules/swarm-worker"

  manager_host  = "${module.swarm_manager.private_ip}"
  key_name      = "${var.swarm_worker_key_pair}"
  instance_type = "${var.swarm_worker_instance_type}"

  vpc_zone_identifier = ["${aws_subnet.private.*.id}"]

  security_groups = [
    "${aws_security_group.swarm_worker_sg.id}",
    "${aws_security_group.swarm_node_sg.id}"
  ]
}
