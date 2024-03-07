locals {
  mumbai_vpc_cidr_block     = "192.168.0.0/16"
  public_subnet_cidr_block  = "192.168.0.0/24"
  private_subnet_cidr_block = "192.168.1.0/24"
  ami_id                    = "ami-0e670eb768a5fc3d4"
  instance_type             = "t2.micro"
}