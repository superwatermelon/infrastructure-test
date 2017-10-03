data "template_file" "swarm_docker_tcp_service" {
  template = <<EOF
[Socket]
ListenStream=2375
BindIPv6Only=both
Service=docker.service
[Install]
WantedBy=sockets.target
EOF
}

data "template_file" "swarm_manager_service" {
  template = <<EOF
[Unit]
After=docker.service
Requires=docker.service
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash -c 'docker swarm init --advertise-addr $(curl http://169.254.169.254/latest/meta-data/local-ipv4)'
[Install]
WantedBy=multi-user.target
EOF
}

data "template_file" "swarm_worker_service" {
  template = <<EOF
[Unit]
Requires=docker.service
After=docker.service
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash -c 'docker swarm join --token $(docker -H $${swarm_manager_host} swarm join-token -q worker) $${swarm_manager_host}'
[Install]
WantedBy=multi-user.target
EOF
  vars {
    swarm_manager_host = "${aws_instance.swarm_manager.private_ip}"
  }
}

data "template_file" "swarm_worker_ignition" {
  template = <<EOF
{
  "ignition":{"version":"2.0.0"},
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
