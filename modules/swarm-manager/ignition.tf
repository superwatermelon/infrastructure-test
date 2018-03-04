data "template_file" "ignition" {
  template = "${file("${path.module}/templates/ignition.tpl")}"

  vars {
    format_swarm            = "${var.format_swarm == true}"
    format_registry         = "${var.format_registry == true}"
    systemd_docker_tcp      = "${jsonencode(module.systemd_docker_tcp.unit)}"
    systemd_swarm_format    = "${jsonencode(module.systemd_swarm_format.unit)}"
    systemd_swarm_mount     = "${jsonencode(module.systemd_swarm_mount.unit)}"
    systemd_registry_format = "${jsonencode(module.systemd_registry_format.unit)}"
    systemd_registry_mount  = "${jsonencode(module.systemd_registry_mount.unit)}"
    systemd_swarm_init      = "${jsonencode(module.systemd_swarm_init.unit)}"
    systemd_docker_registry = "${jsonencode(module.systemd_docker_registry.unit)}"
  }
}
