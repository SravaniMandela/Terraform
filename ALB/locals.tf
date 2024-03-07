locals {
  virginia_vpc_cidr_block     = "192.168.0.0/16"
  public_subnet_cidr_block    = "192.168.0.0/24"
   public_subnet_cidr_block_2    = "192.168.1.0/24"
  private_subnet_cidr_block   = "192.168.11.0/24"
  private_subnet_cidr_block_2 = "192.168.12.0/24"
  region = "us-east-1"
  ami_id                    = "ami-0440d3b780d96b29d"
  instance_type             = "t2.micro"
}