data "template_file" "unit" {
  template = "${file("${path.module}/templates/service.tpl")}"

  vars {
    requires = "${var.requires}"
    after    = "${var.after}"
  }
}
