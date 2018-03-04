data "template_file" "unit" {
  template = "${file("${path.module}/templates/service.tpl")}"

  vars {
    requires    = "${var.requires}"
    after       = "${var.after}"
    image_tag   = "${var.image_tag}"
    host_port   = "${var.host_port}"
    mount_point = "${var.mount_point}"
  }
}
