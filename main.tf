variable "stack_name" {
  description = "The prefix name to prepend to resources"
  default     = "test"
}

variable "hosted_zone" {
  description = "The private hosted zone to use for this VPC."
}

terraform {
  backend "s3" {
    key = "terraform.tfstate"
  }
}

resource "aws_route53_zone" "zone" {
  name    = "${var.hosted_zone}"
  comment = "The private hosted zone"
  vpc_id  = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.stack_name}-zone"
  }
}

resource "aws_route53_record" "swarm_record" {
  zone_id = "${aws_route53_zone.zone.zone_id}"
  name    = "swarm.${var.test_hosted_zone}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.swarm_manager.private_ip}"]
}

resource "aws_security_group" "users_sg" {
  name        = "users"
  description = "Security group for internal users"
  vpc_id      = "${aws_vpc.vpc.id}"
}
