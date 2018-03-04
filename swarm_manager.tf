/*
 * A Swarm cluster with a single Manager.
 */
resource "aws_lb" "swarm_manager" {
  name               = "swarm-manager"
  internal           = true
  subnets            = ["${aws_subnet.data.*.id}"]
  load_balancer_type = "application"

  security_groups = [
    "${aws_security_group.swarm_manager_sg.id}",
    "${aws_security_group.swarm_node_sg.id}",
    "${aws_security_group.registry_sg.id}"
  ]

  tags {
    Environment = "swarm-manager"
  }
}

# Only required in multi-manager cluster
# resource "aws_lb" "swarm_manager_tcp" {
#   name               = "swarm-manager-tcp"
#   internal           = true
#   subnets            = ["${aws_subnet.data.*.id}"]
#   load_balancer_type = "network"
#
#   tags {
#     Environment = "swarm-manager-tcp"
#   }
# }

resource "aws_lb_listener" "registry" {
  load_balancer_arn = "${aws_lb.swarm_manager.arn}"
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${var.certificate_arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.registry.arn}"
    type             = "forward"
  }
}

# Only required in multi-manager cluster
# resource "aws_lb_listener" "docker_client" {
#   load_balancer_arn = "${aws_lb.swarm_manager_tcp.arn}"
#   port              = 2375
#   protocol          = "TCP"
#
#   default_action {
#     target_group_arn = "${aws_lb_target_group.docker_client.arn}"
#     type             = "forward"
#   }
# }

# Only required in multi-manager cluster
# resource "aws_lb_listener" "swarm_comms" {
#   load_balancer_arn = "${aws_lb.swarm_manager_tcp.arn}"
#   port              = 2377
#   protocol          = "TCP"
#
#   default_action {
#     target_group_arn = "${aws_lb_target_group.swarm_comms.arn}"
#     type             = "forward"
#   }
# }

resource "aws_lb_target_group" "registry" {
  name     = "swarm-manager-registry"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.vpc.id}"
}

resource "aws_lb_target_group_attachment" "registry" {
  target_group_arn = "${aws_lb_target_group.registry.arn}"
  target_id        = "${module.swarm_manager.instance_id}"
}

# Only required in multi-manager cluster
# resource "aws_lb_target_group" "docker_client" {
#   name     = "swarm-manager-docker-client"
#   port     = 2375
#   protocol = "TCP"
#   vpc_id   = "${aws_vpc.vpc.id}"
# }

# Only required in multi-manager cluster
# resource "aws_lb_target_group" "swarm_comms" {
#   name     = "swarm-manager-swarm-comms"
#   port     = 2377
#   protocol = "TCP"
#   vpc_id   = "${aws_vpc.vpc.id}"
# }

# Only required in multi-manager cluster
# resource "aws_lb_target_group_attachment" "docker_client" {
#   target_group_arn = "${aws_lb_target_group.docker_client.arn}"
#   target_id        = "${module.swarm_manager.instance_id}"
# }

# Only required in multi-manager cluster
# resource "aws_lb_target_group_attachment" "swarm_comms" {
#   target_group_arn = "${aws_lb_target_group.swarm_comms.arn}"
#   target_id        = "${module.swarm_manager.instance_id}"
# }

module "swarm_manager" {
  source = "./modules/swarm-manager"

  format_swarm      = "${var.swarm_manager_format_data}"
  format_registry   = "${var.docker_registry_format_data}"
  instance_type     = "${var.swarm_manager_instance_type}"
  key_name          = "${var.swarm_manager_key_pair}"
  subnet_id         = "${aws_subnet.data.0.id}"
  availability_zone = "${aws_subnet.data.0.availability_zone}"

  # Documentation suggests that managers should be given a fixed
  # IP address. For a multi-node set up do not use an autoscaling
  # group, instead use a pool of IP addresses and terraform count.
  private_ip        = "${var.swarm_manager_private_ip}"

  vpc_security_group_ids = [
    "${aws_security_group.swarm_manager_sg.id}",
    "${aws_security_group.swarm_node_sg.id}",
    "${aws_security_group.users_sg.id}"
  ]
}
