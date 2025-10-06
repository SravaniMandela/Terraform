provider "aws" {
  # Referencing the variable for the region
  region = var.aws_region
}

resource "aws_vpc" "vpc" {
  # Referencing the variable
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = {
    # Referencing the local value
    Name = local.vpc_name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id 

  tags = {
    # Referencing the local value
    Name = local.igw_name
  }
}

resource "aws_eip" "eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "ngw" {
  allocation_id     = aws_eip.eip.id
  subnet_id         = aws_subnet.publicNAT.id
  connectivity_type = "public"

  tags = {
    # Referencing the local value
    Name = local.natgw_name
  }
}

resource "aws_subnet" "pub" {
  vpc_id                  = aws_vpc.vpc.id
  # Referencing the variable
  cidr_block              = var.public_subnet_cidr
  # Referencing the variable
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.project_name}-Public"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.vpc.id
  # Referencing the variable
  cidr_block        = var.private_subnet_cidr
  # Referencing the variable
  availability_zone = var.availability_zone

  tags = {
    Name = "${local.project_name}-Private"
  }
}

resource "aws_subnet" "publicNAT" {
  vpc_id            = aws_vpc.vpc.id
  # Referencing the variable
  cidr_block        = var.nat_subnet_cidr
  # Referencing the variable
  availability_zone = var.availability_zone

  tags = {
    Name = "${local.project_name}-Public-NAT"
  }
}

resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  route {
    # Referencing the VPC CIDR dynamically
    cidr_block = aws_vpc.vpc.cidr_block 
    gateway_id = "local"
  }

  tags = {
    Name = "${local.project_name}-Public-RT"
  }
}

resource "aws_route_table" "rt2private" {
  vpc_id = aws_vpc.vpc.id

  route {
    # Referencing the VPC CIDR dynamically
    cidr_block = aws_vpc.vpc.cidr_block
    gateway_id = "local"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = "${local.project_name}-Private-RT-New"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.pub.id
  route_table_id = aws_route_table.rt1.id
}

resource "aws_route_table_association" "aNat" {
  subnet_id      = aws_subnet.publicNAT.id
  route_table_id = aws_route_table.rt1.id
}

resource "aws_route_table_association" "a1" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.rt2private.id
}

resource "aws_instance" "ec2" {
  ami                 = data.aws_ami.amazon_linux_2.id 
  instance_type       = var.instance_type
  subnet_id           = aws_subnet.pub.id
  security_groups     = [aws_security_group.sg.id]

  key_name            = var.ssh_key_pair_name
  associate_public_ip_address = true
  tags = {
    Name = " ${local.project_name}-EC2-A"
  }
}

resource "aws_instance" "ec2p" {

  ami                 = data.aws_ami.amazon_linux_2.id 
  instance_type       = var.instance_type
  subnet_id           = aws_subnet.private.id
  security_groups     = [aws_security_group.sgB.id]
  key_name            = var.ssh_key_pair_name
  tags = {
    Name = " ${local.project_name}-EC2-B"
  }
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh_key" {
  # Referencing the variable
  key_name   = var.ssh_key_pair_name
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

resource "aws_security_group" "sg" {
  # Referencing the local value
  name   = local.public_sg_name

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
    Name = "${local.project_name}-EC2-A-SG"
  }
}


resource "aws_security_group" "sgB" {

  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.project_name}-EC2-B-SG"
  }
}