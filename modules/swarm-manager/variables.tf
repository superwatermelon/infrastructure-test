variable "name" {
  description = "The name tag to give the Swarm manager instance"
  default     = "swarm-manager"
}

variable "vpc_security_group_ids" {
  description = "The VPC security group IDs to give the Swarm manager instance"
  type        = "list"
  default     = []
}

variable "subnet_id" {
  description = "The subnet into which to place the Swarm manager instance"
}

variable "availability_zone" {
  description = "The availability zone into which to create EBS volumes"
}

variable "instance_type" {
  description = "The AWS EC2 instance type to provision for the Swarm manager"
}

variable "key_name" {
  description = "The key name to use for SSH access to the Swarm manager"
}

variable "format_swarm" {
  description = "Should the Swarm volume be formatted"
  default     = false
}

variable "format_registry" {
  description = "Should the Registry volume be formatted"
  default     = false
}

variable "swarm_volume_name" {
  description = "The name tag suffix to give the Swarm state volume"
  default = "swarm"
}

variable "swarm_volume_size" {
  description = "The size of the volume used to store Swarm state"
  default = 10
}

variable "swarm_volume_device" {
  description = "The device name for the volume used to store Swarm state"
  default = "xvdf"
}

variable "registry_volume_name" {
  description = "The name tag suffix to give the Docker image registry volume"
  default = "registry"
}

variable "registry_volume_size" {
  description = "The size of the volume used to store Docker images"
  default = 10
}

variable "registry_volume_device" {
  description = "The device name for the volume used to store Docker images"
  default = "xvdg"
}
