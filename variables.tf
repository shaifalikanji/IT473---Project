variable "aws_access_key" {
  description = "AWS Access Key ID"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = true
}
variable "ami_id" {
  description = "AMI for WordPress EC2 instances"
  default     = "ami-0655cec52acf2717b"
}
variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}
variable "env_name" {
  description = "Environment name prefix"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of CIDRs for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDRs for private subnets"
  type        = list(string)
}

variable "public_azs" {
  description = "Availability zones for public subnets"
  type        = list(string)
}

variable "private_azs" {
  description = "Availability zones for private subnets"
  type        = list(string)
}
variable "wp_ami_id" {
  description = "AMI ID for WordPress EC2 instances"
  type        = string
}

variable "wp_instance_type" {
  description = "Instance type for WordPress"
  type        = string
  default     = "t3.micro"
}

variable "efs_mount_point" {
  description = "Mount point for EFS"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

# variable "vpc_id" {
#   description = "VPC ID for resources"
#   type        = string
# }
