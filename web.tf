resource "aws_lb_target_group" "web" {
  name     = "web"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.vpc.id}"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    path                = "/status.html"
    protocol            = "HTTP"
    port                = 8080
    interval            = 30
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = "${module.swarm_worker.asg}"
  alb_target_group_arn   = "${aws_lb_target_group.web.arn}"
}
