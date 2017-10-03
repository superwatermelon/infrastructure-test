#
# Creates a test environment used for automated testing of
# application code. Uses Docker Swarm to deploy applications,
# but is not a High-Availability cluster, the cluster is
# mainly a convenience to have already available infrastructure
# similar to live that can be easily scaled up to support
# many applications in test.
#

variable "vpc_cidr_range" {
  description = "The CIDR range for the VPC"
  default     = "10.128.32.0/22"
}

resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr_range}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "test"
  }
}

resource "aws_default_route_table" "default_rtb" {
  default_route_table_id = "${aws_vpc.vpc.default_route_table_id}"

  tags {
    Name = "test"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "test"
  }
}

resource "aws_route_table" "public_rtb" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
  tags {
    Name = "test-public"
  }
}

output "vpc" {
  value = "${aws_vpc.vpc.id}"
}

output "cidr_block" {
  value = "${aws_vpc.vpc.cidr_block}"
}

output "route_table" {
  value = "${aws_route_table.public_rtb.id}"
}
