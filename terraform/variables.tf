variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "environment" {
  description = "The environment for the deployment (e.g., dev, prod)."
  type        = string
}

variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "public_subnets" {
  description = "A list of CIDR blocks for public subnets."
  type        = list(string)
}

variable "private_subnets" {
  description = "A list of CIDR blocks for private subnets."
  type        = list(string)
}

variable "admin_cidr" {
  description = "The CIDR block allowed to access the EC2 instance via SSH."
  type        = string
}

variable "instance_type" {
  description = "The EC2 instance type."
  type        = string
}

variable "ssh_public_key" {
  description = "The public key for SSH access to the EC2 instance."
  type        = string
}

variable "ssh_private_key_path" {
  description = "The local path to the SSH private key file."
  type        = string
  default     = "~/.ssh/devsecops_key"
}

variable "app_port" {
  description = "The port the application will run on."
  type        = number
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed monitoring for the EC2 instance."
  type        = bool
}

variable "backup_retention_days" {
  description = "The number of days to retain backups."
  type        = number
}

variable "default_tags" {
  description = "A map of default tags to apply to all resources."
  type        = map(string)
  default     = {}
} 