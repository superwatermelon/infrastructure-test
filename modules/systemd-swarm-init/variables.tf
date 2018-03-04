variable "requires" {
  description = "The units that this service requires"
  default     = "docker.service"
}

variable "after" {
  description = "The units that this service should be run after"
  default     = "docker.service"
}
