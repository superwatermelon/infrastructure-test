variable "seed_tfstate_bucket" {
  description = "The name of the S3 bucket hosting seed state"
}

variable "internal_aws_profile" {
  description = "The AWS profile for the internal account access"
}

variable "internal_tfstate_bucket" {
  description = "The name of the S3 bucket hosting internal state"
}

variable "test_tfstate_bucket" {
  description = "The name of the S3 bucket hosting test state"
}

provider "aws" {
  alias   = "internal"
  profile = "${var.internal_aws_profile}"
}

data "aws_caller_identity" "internal" {
  provider = "aws.internal"
}

data "terraform_remote_state" "seed" {
  backend  = "s3"

  config {
    bucket  = "${var.seed_tfstate_bucket}"
    key     = "terraform.tfstate"
    profile = "${var.internal_aws_profile}"
  }
}

data "terraform_remote_state" "internal" {
  backend  = "s3"

  config {
    bucket  = "${data.terraform_remote_state.seed.internal_tfstate_bucket}"
    key     = "terraform.tfstate"
    profile = "${var.internal_aws_profile}"
  }
}

data "terraform_remote_state" "test" {
  backend  = "s3"

  config {
    bucket  = "${data.terraform_remote_state.seed.test_tfstate_bucket}"
    key     = "terraform.tfstate"
  }
}

resource "aws_route" "internal_to_test" {
  provider                  = "aws.internal"
  route_table_id            = "${data.terraform_remote_state.internal.peering_rtb}"
  destination_cidr_block    = "${data.terraform_remote_state.test.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.test.id}"
}

resource "aws_route" "test_to_internal" {
  route_table_id            = "${data.terraform_remote_state.test.peering_rtb}"
  destination_cidr_block    = "${data.terraform_remote_state.internal.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.test.id}"
}

resource "aws_vpc_peering_connection" "test" {
  vpc_id        = "${data.terraform_remote_state.test.vpc_id}"
  peer_vpc_id   = "${data.terraform_remote_state.internal.vpc_id}"
  peer_owner_id = "${data.aws_caller_identity.internal.account_id}"
  auto_accept   = false

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}

resource "aws_vpc_peering_connection_accepter" "internal" {
  provider                  = "aws.internal"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.test.id}"
  auto_accept               = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }
}
