resource "aws_lb" "app" {
  name         = "app"
  idle_timeout = 300

  subnets = [
    "${aws_subnet.dmz.*.id}"
  ]

  security_groups = [
    "${aws_security_group.swarm_load_balancer_sg.id}",
    "${aws_security_group.app.id}"
  ]

  tags {
    Name = "app"
  }
}

resource "aws_lb_listener" "app_https" {
  load_balancer_arn = "${aws_lb.app.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${var.app_cert_arn}"

  # By default forward to the website
  default_action {
    target_group_arn = "${aws_lb_target_group.web.arn}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "app_http" {
  load_balancer_arn = "${aws_lb.app.arn}"
  port              = "80"
  protocol          = "HTTP"

  # By default forward to the website
  default_action {
    target_group_arn = "${aws_lb_target_group.web.arn}"
    type             = "forward"
  }
}

resource "aws_security_group" "app" {
  name        = "app"
  description = "Security group for app ALB"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
