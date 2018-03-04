data "template_file" "ignition" {
  template = "${file("${path.module}/templates/ignition.tpl")}"

  vars {
    systemd_swarm_worker = "${jsonencode(module.systemd_swarm_worker.unit)}"
  }
}
