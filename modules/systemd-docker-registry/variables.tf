variable "requires" {
  description = "The units that this service requires"
  default     = "docker.service"
}

variable "after" {
  description = "The units that this service should be run after"
  default     = "docker.service"
}

variable "image_tag" {
  description = "The version of Docker registry to run"
  default     = "2.5.2"
}

variable "host_port" {
  description = "The port that Docker registry will listen on"
  default     = "5000"
}

variable "mount_point" {
  description = "The mount point for the Docker registry image volume"
  default     = "/var/lib/registry"
}
