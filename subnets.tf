resource "aws_subnet" "dmz" {
  count                   = 3
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.dmz_subnet_cidr_range[count.index]}"
  availability_zone       = "${var.availability_zone[count.index]}"
  map_public_ip_on_launch = true

  tags {
    Name = "test-dmz-${var.availability_zone[count.index]}"
  }
}

resource "aws_route_table_association" "dmz" {
  count          = 3
  subnet_id      = "${element(aws_subnet.dmz.*.id, count.index)}"
  route_table_id = "${aws_route_table.dmz.id}"
}

resource "aws_subnet" "private" {
  count                   = 3
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.private_subnet_cidr_range[count.index]}"
  availability_zone       = "${var.availability_zone[count.index]}"

  # Temporarily keep internet access open
  map_public_ip_on_launch = true

  tags {
    Name = "test-private-${var.availability_zone[count.index]}"
  }
}

resource "aws_route_table_association" "private" {
  count          = 3
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_subnet" "data" {
  count                   = 3
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.data_subnet_cidr_range[count.index]}"
  availability_zone       = "${var.availability_zone[count.index]}"

  # Temporarily keep internet access open
  map_public_ip_on_launch = true

  tags {
    Name = "test-data-${var.availability_zone[count.index]}"
  }
}

resource "aws_route_table_association" "data" {
  count          = 3
  subnet_id      = "${element(aws_subnet.data.*.id, count.index)}"
  route_table_id = "${aws_route_table.data.id}"
}
