/*
 * A Swarm cluster with a single Manager.
 */

variable "swarm_manager_key_pair" {
  description = "The name of the key pair to use for the Swarm Manager node"
}

variable "swarm_worker_key_pair" {
  description = "The name of the key pair to use for the Swarm Worker nodes"
}

variable "swarm_manager_instance_type" {
  description = "The AWS instance type to use for the Swarm Manager node"
  default     = "t2.micro"
}

variable "swarm_worker_instance_type" {
  description = "The AWS instance type to use for the Swarm Worker nodes"
  default     = "t2.nano"
}

variable "desired_swarm_worker_count" {
  description = "The number of Swarm Worker nodes desired"
  default     = 2
}

variable "max_swarm_worker_count" {
  description = "The maximum number of Swarm Worker nodes to allow"
  default     = 9
}

variable "min_swarm_worker_count" {
  description = "The minimum number of Swarm Worker nodes to allow"
  default     = 2
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
    swarm_manager_service    = "${jsonencode(data.template_file.swarm_manager_service.rendered)}"
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
  ami             = "${data.aws_ami.coreos.id}"
  instance_type   = "${var.swarm_manager_instance_type}"
  key_name        = "${var.swarm_manager_key_pair}"
  subnet_id       = "${aws_subnet.subnet.0.id}"
  user_data       = "${data.template_file.swarm_manager_ignition.rendered}"
  security_groups = [
    "${aws_security_group.swarm_manager_sg.id}",
    "${aws_security_group.swarm_node_sg.id}",
    "${aws_security_group.users_sg.id}"
  ]

  tags {
    Name = "${var.stack_name}-swarm-manager"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "swarm_worker" {
  image_id        = "${data.aws_ami.coreos.id}"
  instance_type   = "${var.swarm_worker_instance_type}"
  key_name        = "${var.swarm_worker_key_pair}"
  name_prefix     = "${var.stack_name}-swarm-worker-"
  user_data       = "${data.template_file.swarm_worker_ignition.rendered}"
  security_groups = [
    "${aws_security_group.swarm_worker_sg.id}",
    "${aws_security_group.swarm_node_sg.id}"
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "swarm_worker_asg" {
  desired_capacity     = "${var.desired_swarm_worker_count}"
  launch_configuration = "${aws_launch_configuration.swarm_worker.name}"
  max_size             = "${var.max_swarm_worker_count}"
  min_size             = "${var.min_swarm_worker_count}"
  name                 = "${aws_launch_configuration.swarm_worker.name}-asg"
  vpc_zone_identifier  = ["${aws_subnet.subnet.*.id}"]

  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "${aws_launch_configuration.swarm_worker.name}"
  }
  termination_policies = [
    "OldestLaunchConfiguration",
    "OldestInstance"
  ]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "swarm_manager_sg" {
  name        = "swarm-manager"
  description = "Security group for Swarm managers"
  vpc_id      = "${aws_vpc.vpc.id}"
}

resource "aws_security_group" "swarm_worker_sg" {
  name        = "swarm-worker"
  description = "Security group for Swarm workers"
  vpc_id      = "${aws_vpc.vpc.id}"
}

resource "aws_security_group" "swarm_node_sg" {
  name        = "swarm-worker"
  description = "Security group for Swarm workers"
  vpc_id      = "${aws_vpc.vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "swarm_node_to_node" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = "${aws_security_group.swarm_node_sg.id}"
  security_group_id        = "${aws_security_group.swarm_node_sg.id}"
}

resource "aws_security_group" "swarm_load_balancer_sg" {
  name        = "swarm-worker"
  description = "Security group for Swarm load balancers"
  vpc_id      = "${aws_vpc.vpc.id}"
}

resource "aws_security_group_rule" "swarm_load_balancer_to_worker" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = "${aws_security_group.swarm_load_balancer_sg.id}"
  security_group_id        = "${aws_security_group.swarm_worker_sg.id}"
}

output "swarm_manager_public_ip" {
  value = "${aws_instance.swarm_manager.public_ip}"
}

output "swarm_worker_asg" {
  value = "${aws_autoscaling_group.swarm_worker_asg.id}"
}

output "swarm_load_balancer_sg" {
  value = "${aws_security_group.swarm_load_balancer_sg.id}"
}
