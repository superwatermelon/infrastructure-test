#
# Creates a test environment used for automated testing of
# application code. Uses Docker Swarm to deploy applications,
# but is not a High-Availability cluster, the cluster is
# mainly a convenience to have already available infrastructure
# similar to live that can be easily scaled up to support
# many applications in test.
#

variable "swarm_manager_key_pair" {
  description = "The name of the key pair to associate with the Swarm Manager instance"
}

variable "swarm_worker_key_pair" {
  description = "The name of the key pair to associate with the Swarm Worker instances"
}

variable "aws_region" {
  default = "eu-west-1"
  description = "The AWS region into which to build the infrastructure"
}

variable "availability_zone" {
  default = [
    "eu-west-1a",
    "eu-west-1b",
    "eu-west-1c"
  ]
  description = "The availability zones"
}

variable "stack_name" {
  default = "test"
  description = "The prefix name to prepend to resources"
}

variable "vpc_cidr_range" {
  default = "10.128.32.0/22"
  description = "The CIDR range for the VPC"
}

variable "subnet_cidr_range" {
  default = [
    "10.128.32.0/24",
    "10.128.33.0/24",
    "10.128.34.0/24"
  ]
  description = "The CIDR ranges for the subnets"
}

variable "coreos_owner" {
  default = "595879546273"
  description = "The account ID for the owner of the CoreOS AMI"
}

provider "aws" {
  region = "${var.aws_region}"
}

data "aws_ami" "coreos" {
  most_recent = true
  filter {
    name = "name"
    values = ["CoreOS-stable-*"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["${var.coreos_owner}"]
}

module "swarm" {
  source = "./swarm"
  stack_name = "${var.stack_name}-swarm"
  coreos_ami = "${data.aws_ami.coreos.id}"
  manager_key_pair = "${var.swarm_manager_key_pair}"
  manager_subnet = "${aws_subnet.subnet.0.id}"
  worker_key_pair = "${var.swarm_worker_key_pair}"
  worker_subnets = ["${aws_subnet.subnet.*.id}"]
}

resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr_range}"
  enable_dns_support = true
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
  count = 3
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${var.subnet_cidr_range[count.index]}"
  availability_zone = "${var.availability_zone[count.index]}"
  map_public_ip_on_launch = true
  tags {
    Name = "${var.stack_name}-subnet"
  }
}

resource "aws_route_table_association" "subnet_rtb" {
  count = 3
  subnet_id = "${element(aws_subnet.subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.public_rtb.id}"
}

resource "aws_route53_zone" "zone" {
  name = "test.superwatermelon.org"
  comment = "The internal private hosted zone"
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Name = "${var.stack_name}-zone"
  }
}

resource "aws_route53_record" "git_record" {
  zone_id = "${aws_route53_zone.zone.zone_id}"
  name = "swarm.test.superwatermelon.org"
  type = "A"
  ttl = "300"
  records = ["${module.swarm.manager_public_ip}"]
}

output "swarm_manager_public_ip" {
  value = "${module.swarm.manager_public_ip}"
}
