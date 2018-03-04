module "systemd_docker_tcp" {
  source = "../systemd-docker-tcp"
}

module "systemd_swarm_init" {
  source = "../systemd-swarm-init"

  requires = "docker.service var-lib-docker-swarm.mount"
  after    = "docker.service var-lib-docker-swarm.mount"
}

module "systemd_docker_registry" {
  source = "../systemd-docker-registry"

  requires = "docker.service var-lib-registry.mount"
  after    = "docker.service var-lib-registry.mount"
}

module "systemd_swarm_format" {
  source = "../systemd-format"

  volume = "${var.swarm_volume_device}"
}

module "systemd_swarm_mount" {
  source = "../systemd-mount"

  after       = "format-swarm.service"
  volume      = "${var.swarm_volume_device}1"
  mount_point = "/var/lib/docker/swarm"
}

module "systemd_registry_format" {
  source = "../systemd-format"

  volume = "${var.registry_volume_device}"
}

module "systemd_registry_mount" {
  source = "../systemd-mount"

  after       = "format-registry.service"
  volume      = "${var.registry_volume_device}1"
  mount_point = "/var/lib/registry"
}
