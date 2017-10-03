variable "swarm_worker_key_pair" {
  description = "The name of the key pair to use for the Swarm Worker nodes"
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

output "swarm_worker_asg" {
  value = "${aws_autoscaling_group.swarm_worker_asg.id}"
}
