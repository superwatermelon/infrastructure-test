#
# Creates a test environment used for automated testing of
# application code. Uses Docker Swarm to deploy applications,
# but is not a High-Availability cluster, the cluster is
# mainly a convenience to have already available infrastructure
# similar to live that can be easily scaled up to support
# many applications in test.
#

variable "aws_region" {
  description = "The AWS region into which to build the infrastructure"
  default     = "eu-west-1"
}

variable "availability_zone" {
  description = "The availability zones"
  default     = [
    "eu-west-1a",
    "eu-west-1b",
    "eu-west-1c"
  ]
}

variable "stack_name" {
  description = "The prefix name to prepend to resources"
  default     = "test"
}

variable "vpc_cidr_range" {
  description = "The CIDR range for the VPC"
  default     = "10.128.32.0/22"
}

variable "subnet_cidr_range" {
  description = "The CIDR ranges for the subnets"
  default     = [
    "10.128.32.0/24",
    "10.128.33.0/24",
    "10.128.34.0/24"
  ]
}

variable "coreos_owner" {
  description = "The account ID for the owner of the CoreOS AMI"
  default     = "595879546273"
}

variable "test_hosted_zone" {
  description = "The private hosted zone to use for this VPC."
}

provider "aws" {
  region = "${var.aws_region}"
}

data "aws_ami" "coreos" {
  most_recent = true
  owners      = ["${var.coreos_owner}"]

  filter {
    name = "name"
    values = ["CoreOS-stable-*"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr_range}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "${var.stack_name}-vpc"
  }
}

resource "aws_default_route_table" "default_rtb" {
  default_route_table_id = "${aws_vpc.vpc.default_route_table_id}"

  tags {
    Name = "${var.stack_name}-default-rtb"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.stack_name}-igw"
  }
}

resource "aws_route_table" "public_rtb" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
  tags {
    Name = "${var.stack_name}-public-rtb"
  }
}

resource "aws_subnet" "subnet" {
  count                   = 3
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.subnet_cidr_range[count.index]}"
  availability_zone       = "${var.availability_zone[count.index]}"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.stack_name}-subnet"
  }
}

resource "aws_route_table_association" "subnet_rtb" {
  count          = 3
  subnet_id      = "${element(aws_subnet.subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.public_rtb.id}"
}

resource "aws_route53_zone" "zone" {
  name    = "${var.test_hosted_zone}"
  comment = "The internal private hosted zone"
  vpc_id  = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.stack_name}-zone"
  }
}

resource "aws_route53_record" "swarm_record" {
  zone_id = "${aws_route53_zone.zone.zone_id}"
  name    = "swarm.${var.test_hosted_zone}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.swarm_manager.private_ip}"]
}

resource "aws_security_group" "users_sg" {
  name        = "users"
  description = "Security group for internal users"
  vpc_id      = "${aws_vpc.vpc.id}"
}

output "vpc" {
  value = "${aws_vpc.vpc.id}"
}

output "cidr_block" {
  value = "${aws_vpc.vpc.cidr_block}"
}

output "subnets" {
  value = ["${aws_subnet.subnet.*.id}"]
}

output "route_table" {
  value = "${aws_route_table.public_rtb.id}"
}
