module "systemd_swarm_worker" {
  source = "../systemd-swarm-worker"

  manager_host = "${var.manager_host}"
}
