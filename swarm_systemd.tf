data "template_file" "swarm_docker_tcp_service" {
  template = "${file("${path.module}/templates/docker_socket_systemd.tpl")}"
}

data "template_file" "swarm_manager_init_service" {
  template = "${file("${path.module}/templates/swarm_manager_init_systemd.tpl")}"
}

data "template_file" "swarm_worker_service" {
  template = "${file("${path.module}/templates/swarm_worker_systemd.tpl")}"
  vars {
    swarm_manager_host = "${aws_instance.swarm_manager.private_ip}"
  }
}

data "template_file" "swarm_manager_data_service_unit" {
  template = "${file("${path.module}/templates/swarm_manager_data_systemd.tpl")}"
}

data "template_file" "var_lib_docker_swarm_mount_unit" {
  template = "${file("${path.module}/templates/var_lib_docker_swarm_systemd.tpl")}"
  vars {
    volume = "${var.swarm_manager_volume_device}"
  }
}

data "template_file" "swarm_manager_data_format_service" {
  template = "${file("${path.module}/templates/swarm_manager_data_format_systemd.tpl")}"
  vars {
    volume = "${var.swarm_manager_volume_device}"
  }
}
