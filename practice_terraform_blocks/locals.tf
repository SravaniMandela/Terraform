locals {
 
  project_name = "VPC-A"
  common_tags = {
    Project = local.project_name
  }
  vpc_name          = local.project_name
  igw_name          = "${local.project_name}-IGW"
  natgw_name        = "${local.project_name}-NATGW"
  public_sg_name    = "first-sg" 
}