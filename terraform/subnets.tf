variable "availability_zone" {
  description = "The availability zones"
  default     = [
    "eu-west-1a",
    "eu-west-1b",
    "eu-west-1c"
  ]
}

variable "dmz_subnet_cidr_range" {
  description = "The CIDR ranges for the subnets"
  default     = [
    "10.128.32.0/26",
    "10.128.32.64/26",
    "10.128.32.128/26"
  ]
}

variable "private_subnet_cidr_range" {
  description = "The CIDR ranges for the subnets"
  default     = [
    "10.128.33.0/26",
    "10.128.33.64/26",
    "10.128.33.128/26"
  ]
}

variable "data_subnet_cidr_range" {
  description = "The CIDR ranges for the subnets"
  default     = [
    "10.128.34.0/26",
    "10.128.34.64/26",
    "10.128.34.128/26"
  ]
}

resource "aws_subnet" "dmz" {
  count                   = 3
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.dmz_subnet_cidr_range[count.index]}"
  availability_zone       = "${var.availability_zone[count.index]}"
  map_public_ip_on_launch = true

  tags {
    Name = "test-dmz"
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
    Name = "test-private"
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
    Name = "test-data"
  }
}

resource "aws_route_table_association" "data" {
  count          = 3
  subnet_id      = "${element(aws_subnet.data.*.id, count.index)}"
  route_table_id = "${aws_route_table.data.id}"
}

output "dmz_subnets" {
  value = ["${aws_subnet.dmz.*.id}"]
}

output "private_subnets" {
  value = ["${aws_subnet.private.*.id}"]
}

output "data_subnets" {
  value = ["${aws_subnet.data.*.id}"]
}
