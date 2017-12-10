data "template_file" "swarm_manager_ignition" {
  template = "${file("${path.module}/templates/swarm_manager_ignition.tpl")}"
  vars {
    swarm_docker_tcp_service                  = "${jsonencode(data.template_file.swarm_docker_tcp_service.rendered)}"
    swarm_manager_init_service                = "${jsonencode(data.template_file.swarm_manager_init_service.rendered)}"
    var_lib_docker_swarm_mount                = "${jsonencode(data.template_file.var_lib_docker_swarm_mount_unit.rendered)}"
    swarm_manager_data_format_service         = "${jsonencode(data.template_file.swarm_manager_data_format_service.rendered)}"
    swarm_manager_data_format_service_enabled = "${var.swarm_manager_format_data == true}"
  }
}

data "template_file" "swarm_worker_ignition" {
  template = "${file("${path.module}/templates/swarm_worker_ignition.tpl")}"
  vars {
    swarm_worker_service = "${jsonencode(data.template_file.swarm_worker_service.rendered)}"
  }
}
