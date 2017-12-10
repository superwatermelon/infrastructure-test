output "swarm_worker_asg" {
  value = "${aws_autoscaling_group.swarm_worker_asg.id}"
}

output "swarm_manager_public_ip" {
  value = "${aws_instance.swarm_manager.public_ip}"
}

output "swarm_manager_private_ip" {
  value = "${aws_instance.swarm_manager.private_ip}"
}

output "hosted_zone_id" {
  value = "${aws_route53_zone.zone.id}"
}

output "swarm_load_balancer_sg" {
  value = "${aws_security_group.swarm_load_balancer_sg.id}"
}

output "swarm_manager_sg" {
  value = "${aws_security_group.swarm_manager_sg.id}"
}

output "swarm_worker_sg" {
  value = "${aws_security_group.swarm_worker_sg.id}"
}

output "dmz_subnets" {
  value = ["${aws_subnet.dmz.*.id}"]
}

output "private_subnets" {
  value = ["${aws_subnet.private.*.id}"]
}

output "data_subnets" {
  value = ["${aws_subnet.data.*.id}"]
}
