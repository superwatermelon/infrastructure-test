resource "aws_default_security_group" "default_sg" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "test"
  }
}

resource "aws_security_group" "users_sg" {
  name        = "users"
  description = "Internal users"
  vpc_id      = "${aws_vpc.vpc.id}"

  tags {
    Name = "users"
  }
}

resource "aws_security_group" "swarm_manager_sg" {
  name        = "swarm-manager"
  description = "Swarm managers"
  vpc_id      = "${aws_vpc.vpc.id}"

  tags {
    Name = "swarm-manager"
  }
}

resource "aws_security_group" "swarm_worker_sg" {
  name        = "swarm-worker"
  description = "Swarm workers"
  vpc_id      = "${aws_vpc.vpc.id}"

  tags {
    Name = "swarm-worker"
  }
}

resource "aws_security_group" "swarm_node_sg" {
  name        = "swarm-node"
  description = "Swarm node"
  vpc_id      = "${aws_vpc.vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "swarm-node"
  }
}

resource "aws_security_group" "docker_registry_sg" {
  name        = "docker-registry"
  description = "Docker Registry"
  vpc_id      = "${aws_vpc.vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "docker-registry"
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
  name        = "swarm-load-balancer"
  description = "Security group for Swarm load balancers"
  vpc_id      = "${aws_vpc.vpc.id}"

  tags {
    Name = "swarm-load-balancer"
  }
}

resource "aws_security_group_rule" "swarm_load_balancer_to_worker" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = "${aws_security_group.swarm_worker_sg.id}"
  security_group_id        = "${aws_security_group.swarm_load_balancer_sg.id}"
}

resource "aws_security_group_rule" "swarm_worker_from_load_balancer" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = "${aws_security_group.swarm_load_balancer_sg.id}"
  security_group_id        = "${aws_security_group.swarm_worker_sg.id}"
}
