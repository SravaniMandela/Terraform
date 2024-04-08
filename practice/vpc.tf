provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "main" {
  cidr_block       =  local.vpc_cidr_block
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

resource "aws_eip" "eip" {
  domain   = "vpc"
}
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "NAT"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "IGW"
  }
}

resource "aws_subnet" "public" {
    vpc_id = aws_vpc.main.id
  cidr_block = local.public_subnet_cidr_block
  tags = {
    Name = "public_subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = local.private_subnet_cidr_block

  tags = {
    Name = "private_subnet"
  }
}

resource "aws_route_table" "public_RT" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block           = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public_rt"
  }
}

resource "aws_route_table" "private_R" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block           = "0.0.0.0/0"
    gateway_id     = aws_nat_gateway.ngw.id
  }
  tags = {
    Name = "private_rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_RT.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_R.id
}

resource "aws_instance" "ec2" {
  ami           = "ami-051f8a213df8bc089"
  instance_type = "t2.micro"
  subnet_id =  aws_subnet.public.id
  key_name = aws_key_pair.instance_key.key_name
  security_groups = [aws_security_group.sgPublic.id]
  associate_public_ip_address = true
  tags = {
    Name = "EC2-A"
  }
}

resource "aws_instance" "ec2Private" {
  ami           = "ami-051f8a213df8bc089"
  instance_type = "t2.micro"
  subnet_id =  aws_subnet.public.id
  key_name = aws_key_pair.instance_key.key_name
  security_groups = [aws_security_group.sgPrivate.id]
  tags = {
    Name = "EC2-B"
  }
}

# key pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "instance_key" {
  key_name   = "vpc_key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "local_file" "foo" {
  content  = "${tls_private_key.ssh_key.private_key_pem}"
  filename = "${path.module}/key.pem"
}


 resource "aws_security_group" "sgPublic" {
    name        = "first-sg"
  
    vpc_id = aws_vpc.main.id
  
    ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

     ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
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

   resource "aws_security_group" "sgPrivate" {
    name        = "second-sg"
  
    vpc_id = aws_vpc.main.id
  
    ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [local.public_subnet_cidr_block]
    }

     ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [local.public_subnet_cidr_block]
  }
  
    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = [local.public_subnet_cidr_block]
    }
  
    tags = {
      Name = "EC2-B-SG"
    }
  }
  
  