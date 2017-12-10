# ----- REQUIRED VARIABLES ----- #

variable "swarm_worker_key_pair" {
  description = "The name of the key pair to use for the Swarm Worker nodes"
}

variable "swarm_manager_key_pair" {
  description = "The name of the key pair to use for the Swarm Manager node"
}

variable "hosted_zone" {
  description = "The private hosted zone to use for this VPC."
}

# ----- OPTIONAL VARIABLES ----- #

variable "swarm_manager_volume_device" {
  description = "The device name of the Swarm Manager volume"
  default     = "xvdk"
}

variable "swarm_manager_format_data" {
  description = "Should the data for the Swarm Manager be formatted"
  default     = false
}

variable "swarm_manager_instance_type" {
  description = "The AWS instance type to use for the Swarm Manager node"
  default     = "t2.micro"
}

variable "coreos_owner" {
  description = "The account ID for the owner of the CoreOS AMI"
  default     = "595879546273"
}

variable "swarm_worker_instance_type" {
  description = "The AWS instance type to use for the Swarm Worker nodes"
  default     = "t2.nano"
}

variable "desired_swarm_worker_count" {
  description = "The number of Swarm Worker nodes desired"
  default     = 2
}

variable "max_swarm_worker_count" {
  description = "The maximum number of Swarm Worker nodes to allow"
  default     = 9
}

variable "min_swarm_worker_count" {
  description = "The minimum number of Swarm Worker nodes to allow"
  default     = 2
}

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
