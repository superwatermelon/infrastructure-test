resource "aws_autoscaling_group" "worker" {
  desired_capacity     = "${var.desired_capacity}"
  launch_configuration = "${aws_launch_configuration.worker.name}"
  max_size             = "${var.max_size}"
  min_size             = "${var.min_size}"
  name                 = "${var.name}"
  vpc_zone_identifier  = ["${var.vpc_zone_identifier}"]

  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "${aws_launch_configuration.worker.name}"
  }

  termination_policies = [
    "OldestLaunchConfiguration",
    "OldestInstance"
  ]
}
