variable "availability_zone" {
  description = "The availability zones"
  default     = [
    "eu-west-1a",
    "eu-west-1b",
    "eu-west-1c"
  ]
}

variable "subnet_cidr_range" {
  description = "The CIDR ranges for the subnets"
  default     = [
    "10.128.32.0/24",
    "10.128.33.0/24",
    "10.128.34.0/24"
  ]
}

resource "aws_subnet" "subnet" {
  count                   = 3
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.subnet_cidr_range[count.index]}"
  availability_zone       = "${var.availability_zone[count.index]}"
  map_public_ip_on_launch = true

  tags {
    Name = "test"
  }
}

resource "aws_route_table_association" "subnet_rtb" {
  count          = 3
  subnet_id      = "${element(aws_subnet.subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.public_rtb.id}"
}

output "subnets" {
  value = ["${aws_subnet.subnet.*.id}"]
}
