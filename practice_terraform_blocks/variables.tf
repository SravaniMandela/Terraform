# variables.tf

variable "aws_region" {
  description = "The AWS region to deploy resources into."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the main VPC."
  type        = string
  default     = "10.100.0.0/16"
}

variable "availability_zone" {
  description = "The Availability Zone to use for subnets."
  type        = string
  default     = "us-east-1a"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the general public subnet."
  type        = string
  default     = "10.100.0.0/24"
}

variable "nat_subnet_cidr" {
  description = "CIDR block for the dedicated public subnet hosting the NAT Gateway."
  type        = string
  default     = "10.100.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private application subnet."
  type        = string
  default     = "10.100.11.0/24"
}

# variable "instance_ami" {
#   description = "AMI ID for the EC2 instances."
#   type        = string
#   default     = "ami-0cf10cdf9fcd62d37"
# }

variable "instance_type" {
  description = "Instance type for the EC2 instances."
  type        = string
  default     = "t2.micro"
}

variable "ssh_key_pair_name" {
  description = "The name for the AWS Key Pair resource."
  type        = string
  default     = "my-ssh-key"
}