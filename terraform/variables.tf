variable "db_admin_ip" {
  type        = string
  default     = "176.186.2.251/32"
  description = "IP address of the allowedMongoDB Express Admin User."
}

variable "certificate_arn" {
  description = "certificate ARN"
  type        = string
}
