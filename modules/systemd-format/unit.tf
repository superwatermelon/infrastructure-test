data "template_file" "unit" {
  template = "${file("${path.module}/templates/service.tpl")}"

  vars {
    volume = "${var.volume}"
  }
}
