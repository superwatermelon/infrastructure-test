variable "name" {
  description = "The name to give Swarm workers"
  default     = "swarm-worker"
}

variable "name_prefix" {
  description = "The name prefix to give the Swarm worker instances"
  default     = "swarm-worker-"
}

variable "security_groups" {
  description = "The VPC security group IDs to give the Swarm worker instances"
  type        = "list"
  default     = []
}

variable "desired_capacity" {
  description = "The desired number of workers to launch"
  default     = 3
}

variable "max_size" {
  description = "The maximum number of workers to launch"
  default     = 20
}

variable "min_size" {
  description = "The minimum number of workers to launch"
  default     = 1
}

variable "vpc_zone_identifier" {
  description = "List of subnets to launch Swarm workers in"
  type        = "list"
}

variable "instance_type" {
  description = "The AWS EC2 instance type to provision for the Swarm workers"
}

variable "key_name" {
  description = "The key name to use for SSH access to the Swarm workers"
}

variable "manager_host" {
  description = "The address of a Swarm manager host"
}
