variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "os_type" {
  description = "Operating System type to use (amazon-linux or ubuntu)"
  type        = string
  default     = "amazon-linux"
  validation {
    condition     = contains(["amazon-linux", "ubuntu"], var.os_type)
    error_message = "Valid values for os_type are 'amazon-linux' or 'ubuntu'."
  }
}

variable "key_name" {
  description = "SSH key pair name (must exist in the region)"
  type        = string
}

variable "project_name" {
  description = "Name prefix for resources"
  type        = string
  default     = "picoclaw-finops-copilot"
}
