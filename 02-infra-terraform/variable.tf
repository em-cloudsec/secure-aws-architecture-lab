variable "aws_region" {
  description = "AWS region to deploy the lab into"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "A short name prefix for all resources"
  type        = string
  default     = "secure-aws-lab"
}

variable "vpc_cidr" {
  description = "CIDR block for the lab VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}
