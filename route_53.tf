resource "aws_route53_zone" "zone" {
  name    = "${var.hosted_zone}"
  comment = "The private hosted zone"
  vpc_id  = "${aws_vpc.vpc.id}"

  tags {
    Name = "test"
  }
}

resource "aws_route53_record" "swarm_record" {
  zone_id = "${aws_route53_zone.zone.zone_id}"
  name    = "swarm.${var.hosted_zone}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.swarm_manager.private_ip}"]
}
