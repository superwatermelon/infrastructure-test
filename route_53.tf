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
  ttl     = 300
  records = ["${module.swarm_manager.private_ip}"]
}

resource "aws_route53_record" "cert_validation" {
  zone_id = "${aws_route53_zone.zone.zone_id}"
  name    = "${var.certificate_verification_dns_name}"
  type    = "CNAME"
  ttl     = 300
  records = ["${var.certificate_verification_dns_value}"]
}
