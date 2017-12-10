resource "aws_launch_configuration" "swarm_worker" {
  image_id        = "${data.aws_ami.coreos.id}"
  instance_type   = "${var.swarm_worker_instance_type}"
  key_name        = "${var.swarm_worker_key_pair}"
  name_prefix     = "swarm-worker-"
  user_data       = "${data.template_file.swarm_worker_ignition.rendered}"
  security_groups = [
    "${aws_security_group.swarm_worker_sg.id}",
    "${aws_security_group.swarm_node_sg.id}"
  ]
}

resource "aws_autoscaling_group" "swarm_worker_asg" {
  desired_capacity     = "${var.desired_swarm_worker_count}"
  launch_configuration = "${aws_launch_configuration.swarm_worker.name}"
  max_size             = "${var.max_swarm_worker_count}"
  min_size             = "${var.min_swarm_worker_count}"
  name                 = "${aws_launch_configuration.swarm_worker.name}-asg"
  vpc_zone_identifier  = ["${aws_subnet.private.*.id}"]

  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "${aws_launch_configuration.swarm_worker.name}"
  }
  termination_policies = [
    "OldestLaunchConfiguration",
    "OldestInstance"
  ]
}
