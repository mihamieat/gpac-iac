variable "vpc_id" {
  description = "vpc ID"
  type        = string
}

variable "certificate_arn" {
  description = "certificate ARN"
  type        = string
}

variable "health_check_path" {
  description = "Path for the Target Group health check"
  type        = string
}

variable "target_instance_ids" {
  description = "List of instance IDs to attach to the Target Group"
  type        = list(string)
}

variable "security_groups" {
  description = "List of security groups for the Load Balancer"
  type        = list(string)
}

variable "subnet_ids" {
  description = "Subnet IDs for the Load Balancer"
  type        = list(string)
}
