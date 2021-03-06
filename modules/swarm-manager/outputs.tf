output "public_ip" {
  value = "${aws_instance.manager.public_ip}"
}

output "private_ip" {
  value = "${aws_instance.manager.private_ip}"
}

output "instance_id" {
  value = "${aws_instance.manager.id}"
}
