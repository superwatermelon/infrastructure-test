/*
 * A Swarm cluster with a single Manager.
 */
resource "aws_lb" "swarm_manager" {
  name            = "swarm-manager"
  internal        = true
  security_groups = [
    "${aws_security_group.swarm_manager_sg.id}",
    "${aws_security_group.registry_sg.id}"
  ]
  subnets         = ["${aws_subnet.data.*.id}"]

  tags {
    Environment = "swarm-manager"
  }
}

resource "aws_lb_listener" "swarm_manager" {
  load_balancer_arn = "${aws_lb.swarm_manager.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${var.certificate_arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.registry.arn}"
    type             = "forward"
  }
}

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

resource "aws_lb_target_group" "swarm" {
  name     = "swarm-manager-swarm"
  port     = 2375
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.vpc.id}"
}

resource "aws_lb_target_group_attachment" "swarm" {
  target_group_arn = "${aws_lb_target_group.swarm.arn}"
  target_id        = "${module.swarm_manager.instance_id}"
}

module "swarm_manager" {
  source = "./modules/swarm-manager"

  format_swarm      = "${var.swarm_manager_format_data}"
  format_registry   = "${var.docker_registry_format_data}"
  instance_type     = "${var.swarm_manager_instance_type}"
  key_name          = "${var.swarm_manager_key_pair}"
  subnet_id         = "${aws_subnet.data.0.id}"
  availability_zone = "${aws_subnet.data.0.availability_zone}"

  vpc_security_group_ids = [
    "${aws_security_group.swarm_manager_sg.id}",
    "${aws_security_group.swarm_node_sg.id}",
    "${aws_security_group.users_sg.id}"
  ]
}
