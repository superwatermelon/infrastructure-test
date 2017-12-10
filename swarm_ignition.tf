data "template_file" "swarm_manager_ignition" {
  template = <<EOF
{
  "ignition":{"version":"2.0.0"},
  "storage": {
    "files": [{
      "filesystem": "root",
      "path": "/etc/coreos/docker-1.12",
      "contents": { "source": "data:,no%0A" }
    }]
  },
  "systemd":{
    "units":[
      {"name":"docker.socket","enable":true},
      {"name":"containerd.service","enable":true},
      {"name":"docker.service","enable":true},
      {"name":"docker-tcp.socket","enable":true,"contents":$${swarm_docker_tcp_service}},
      {"name":"swarm-manager-init.service","enable":$${swarm_manager_init},"contents":$${swarm_manager_init_service}}
      {"name":"swarm-manager-join.service","enable":$${swarm_manager_join},"contents":$${swarm_manager_join_service}}
    ]
  }
}
EOF
  vars {
    swarm_docker_tcp_service   = "${jsonencode(data.template_file.swarm_docker_tcp_service.rendered)}"
    swarm_manager_init_service = "${jsonencode(data.template_file.swarm_manager_init_service.rendered)}"
    swarm_manager_join_service = "${jsonencode(data.template_file.swarm_manager_join_service.rendered)}"
    swarm_manager_init         = "${var.join_swarm_manager_host == false}"
    swarm_manager_join         = "${var.join_swarm_manager_host != false}"
  }
}

data "template_file" "swarm_worker_ignition" {
  template = <<EOF
{
  "ignition":{"version":"2.0.0"},
  "storage": {
    "files": [{
      "filesystem": "root",
      "path": "/etc/coreos/docker-1.12",
      "contents": { "source": "data:,no%0A" }
    }]
  },
  "systemd":{
    "units":[
      {"name":"docker.socket","enable":true},
      {"name":"containerd.service","enable":true},
      {"name":"docker.service","enable":true},
      {"name":"swarm-worker.service","enable":true,"contents":$${swarm_worker_service}}
    ]
  }
}
EOF
  vars {
    swarm_worker_service = "${jsonencode(data.template_file.swarm_worker_service.rendered)}"
  }
}
