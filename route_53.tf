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

  alias {
    name                   = "${aws_lb.swarm_manager.dns_name}"
    zone_id                = "${aws_lb.swarm_manager.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "registry_record" {
  zone_id = "${aws_route53_zone.zone.zone_id}"
  name    = "registry.${var.hosted_zone}"
  type    = "A"

  alias {
    name                   = "${aws_lb.swarm_manager.dns_name}"
    zone_id                = "${aws_lb.swarm_manager.zone_id}"
    evaluate_target_health = true
  }
}
