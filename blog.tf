module "blog" {
  source = "github.com/superwatermelon/superwatermelon-blog-infrastructure"
  artifact_bucket_name = "${var.blog_artifact_bucket_name}"
  vpc_id = "${aws_vpc.vpc.id}"
  asg_id = "${module.swarm_worker.asg}"
  http_listener_arn = "${aws_lb_listener.app_http.arn}"
  https_listener_arn = "${aws_lb_listener.app_https.arn}"
  host = "blog.${var.public_hosted_zone}"
}
