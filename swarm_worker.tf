module "swarm_worker" {
  source = "./modules/swarm-worker"

  # Only required in multi-manager cluster
  # manager_host  = "swarm.${var.hosted_zone}"

  manager_host  = "${module.swarm_manager.private_ip}"
  key_name      = "${var.swarm_worker_key_pair}"
  instance_type = "${var.swarm_worker_instance_type}"
  name_prefix   = "swarm-worker-${module.swarm_manager.id}-"

  vpc_zone_identifier = ["${aws_subnet.private.*.id}"]

  security_groups = [
    "${aws_security_group.swarm_worker_sg.id}",
    "${aws_security_group.swarm_node_sg.id}"
  ]

  tags {
    manager = "${module.swarm_manager.instance_id}"
  }
}
