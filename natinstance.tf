provider "aws" {
    region = "us-east-1"
  }
  
  resource "aws_vpc" "vpc" {
    cidr_block       = "10.100.0.0/16"
    instance_tenancy = "default"
  
    tags = {
      Name = "VPC-A"
    }
  }
  
  resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id     
  
    tags = {
      Name = "VPC-A-IGW"
    }
  }

  resource "aws_eip" "eip" {
    domain   = "vpc"
  }

  
  resource "aws_subnet" "pub" {
    vpc_id     = aws_vpc.vpc.id
    cidr_block = "10.100.0.0/24"
    availability_zone="us-east-1a"
    map_public_ip_on_launch = true
  
    tags = {
      Name = "VPC-A-Public"
    }
  }

  resource "aws_subnet" "private" {
    vpc_id     = aws_vpc.vpc.id
    cidr_block = "10.100.11.0/24"
    availability_zone="us-east-1a"
  
    tags = {
      Name = "VPC-A-Private"
    }
  }

  resource "aws_subnet" "publicNAT" {
    vpc_id     = aws_vpc.vpc.id
    cidr_block = "10.100.1.0/24"
    availability_zone="us-east-1a"
  
    tags = {
      Name = "VPC-A-Public-NAT"
    }
  }

  
  resource "aws_route_table" "rt1" {
    vpc_id = aws_vpc.vpc.id
  
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
    }
    route {
      cidr_block = "10.100.0.0/16"
      gateway_id = "local"
    }
  
    tags = {
      Name = "VPC-A-Public-RT"
    }
  }

 

  resource "aws_instance" "ec2nat" {
    ami           = "ami-0780b09c119334593"
    instance_type = "t2.micro"
    subnet_id     = aws_subnet.publicNAT.id
    security_groups = [aws_security_group.sgNAT.id]
    key_name      = aws_key_pair.ssh_key.key_name
    associate_public_ip_address = true
    source_dest_check = false
    tags = {
      Name = " EC2-NAT"
    }
 
  }

  resource "aws_route_table" "rt2private" {
    vpc_id = aws_vpc.vpc.id

    route {
      cidr_block = "0.0.0.0/0"
      network_interface_id = aws_instance.ec2nat.primary_network_interface_id  
    }
  
    route {
      cidr_block = "10.100.0.0/16"
      gateway_id = "local"
    }
  
    tags = {
      Name = "VPC-A-Private-RT-New"
    }
  }
  
  resource "aws_route_table_association" "a" {
    subnet_id      = aws_subnet.pub.id
    route_table_id = aws_route_table.rt1.id
  }

  resource "aws_route_table_association" "aNat" {
    subnet_id = aws_subnet.publicNAT.id
    route_table_id = aws_route_table.rt1.id
  }

  resource "aws_route_table_association" "a1" {
    subnet_id      = aws_subnet.private.id
    route_table_id = aws_route_table.rt2private.id
  }

  resource "aws_instance" "ec2" {
    ami           = "ami-0cf10cdf9fcd62d37"
    instance_type = "t2.micro"
    subnet_id     = aws_subnet.pub.id
    security_groups = [aws_security_group.sg.id]
    key_name      = aws_key_pair.ssh_key.key_name
    associate_public_ip_address = true
    tags = {
      Name = " EC2-A"
    }
 
  }

  resource "aws_instance" "ec2p" {
    ami           = "ami-0cf10cdf9fcd62d37"
    instance_type = "t2.micro"
    subnet_id     = aws_subnet.private.id
    security_groups = [aws_security_group.sgB.id]
    key_name      = aws_key_pair.ssh_key.key_name
    tags = {
      Name = " EC2-B"
    }

 
  }
  
  resource "tls_private_key" "ssh_key" {
    algorithm = "RSA"
    rsa_bits  = 4096
  }
  
  resource "aws_key_pair" "ssh_key" {
    key_name   = "my-ssh-key"
    public_key = tls_private_key.ssh_key.public_key_openssh
  }
  
  output "private_key" {
    value     = tls_private_key.ssh_key.private_key_pem
    sensitive = true
  }
  
  output "public_key" {
    value     = tls_private_key.ssh_key.public_key_openssh
    sensitive = true
  }

  output "instanceid" {
    value     = aws_instance.ec2nat.id
  }
  
  resource "aws_security_group" "sg" {
    name        = "first-sg"
  
    vpc_id = aws_vpc.vpc.id
  
    ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  
    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  
    tags = {
      Name = "EC2-A-SG"
    }
  }
  
   
 

  resource "aws_security_group" "sgB" {
  
    vpc_id = aws_vpc.vpc.id
  
    ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.100.0.0/16"]
    }

    ingress {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = ["10.100.0.0/16"]
    }

    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  
    tags = {
      Name = "EC2-B-SG"
    }
  }

  resource "aws_security_group" "sgNAT" {
  
    vpc_id = aws_vpc.vpc.id
  
    ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["10.100.0.0/16"]
    }

    ingress {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["10.100.0.0/16"]
    }
    ingress {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = ["10.100.0.0/16"]
    }

    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  
    tags = {
      Name = "EC2-SG-NAT"
    }
  }
  
   
 