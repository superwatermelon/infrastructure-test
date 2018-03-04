data "template_file" "unit" {
  template = "${file("${path.module}/templates/service.tpl")}"

  vars {
    manager_host = "${var.manager_host}"
  }
}
