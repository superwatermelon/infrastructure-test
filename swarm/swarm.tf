/*
 * A Swarm cluster with a single Manager.
 */

variable "coreos_ami" {
  description = "The CoreOS AMI to use for both Swarm Manager and Worker nodes"
}

variable "manager_key_pair" {
  description = "The name of the key pair to use for the Swarm Manager node"
}

variable "manager_subnet" {
  description = "The subnet into which to deploy the Swarm Manager node"
}

variable "manager_instance_type" {
  default = "t2.micro"
  description = "The AWS instance type to use for the Swarm Manager node"
}

variable "worker_key_pair" {
  description = "The name of the key pair to use for the Swarm Worker nodes"
}

variable "worker_subnets" {
  type = "list"
  description = "The subnets into which to deploy Swarm Worker nodes"
}

variable "worker_instance_type" {
  default = "t2.nano"
  description = "The AWS instance type to use for the Swarm Worker nodes"
}

variable "stack_name" {
  default = "swarm"
  description = "The name to prefix resources"
}

variable "desired_worker_count" {
  default = 2
  description = "The number of Swarm Worker nodes desired"
}

variable "max_worker_count" {
  default = 9
  description = "The maximum number of Swarm Worker nodes to allow"
}

variable "min_worker_count" {
  default = 2
  description = "The minimum number of Swarm Worker nodes to allow"
}

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

data "template_file" "swarm_manager_ignition" {
  template = <<EOF
{
  "ignition":{"version":"2.0.0"},
  "systemd":{
    "units":[
      {"name":"docker.socket","enable":true},
      {"name":"containerd.service","enable":true},
      {"name":"docker.service","enable":true},
      {"name":"docker-tcp.socket","enable":true,"contents":$${swarm_docker_tcp_service}},
      {"name":"swarm-manager.service","enable":true,"contents":$${swarm_manager_service}}
    ]
  }
}
EOF
  vars {
    swarm_docker_tcp_service = "${jsonencode(data.template_file.swarm_docker_tcp_service.rendered)}"
    swarm_manager_service = "${jsonencode(data.template_file.swarm_manager_service.rendered)}"
  }
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

resource "aws_instance" "swarm_manager" {
  lifecycle {
    create_before_destroy = true
  }
  ami = "${var.coreos_ami}"
  instance_type = "${var.manager_instance_type}"
  key_name = "${var.manager_key_pair}"
  subnet_id = "${var.manager_subnet}"
  tags {
    Name = "${var.stack_name}-manager"
  }
  user_data = "${data.template_file.swarm_manager_ignition.rendered}"
}

resource "aws_launch_configuration" "swarm_worker" {
  lifecycle {
    create_before_destroy = true
  }
  image_id = "${var.coreos_ami}"
  instance_type = "${var.worker_instance_type}"
  key_name = "${var.worker_key_pair}"
  name_prefix = "${var.stack_name}-worker-"
  user_data = "${data.template_file.swarm_worker_ignition.rendered}"
}

resource "aws_autoscaling_group" "swarm_worker_asg" {
  lifecycle {
    create_before_destroy = true
  }
  desired_capacity = "${var.desired_worker_count}"
  launch_configuration = "${aws_launch_configuration.swarm_worker.name}"
  max_size = "${var.max_worker_count}"
  min_size = "${var.min_worker_count}"
  name = "${aws_launch_configuration.swarm_worker.name}-asg"
  tag {
    key = "Name"
    propagate_at_launch = true
    value = "${aws_launch_configuration.swarm_worker.name}"
  }
  termination_policies = [
    "OldestLaunchConfiguration",
    "OldestInstance"
  ]
  vpc_zone_identifier = ["${var.worker_subnets}"]
}

output "manager_public_ip" {
  value = "${aws_instance.swarm_manager.public_ip}"
}
