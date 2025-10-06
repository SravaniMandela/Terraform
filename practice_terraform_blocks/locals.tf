# locals.tf

locals {
  # Base name used for all resources
  project_name = "VPC-A"

  # Simplified tag map for common use
  common_tags = {
    Project = local.project_name
  }

  # Specific names derived from the project_name
  vpc_name          = local.project_name
  igw_name          = "${local.project_name}-IGW"
  natgw_name        = "${local.project_name}-NATGW"
  public_sg_name    = "first-sg" # Retain original security group name structure if desired
}