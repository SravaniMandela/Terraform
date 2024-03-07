resource "aws_vpc" "mumbai_vpc" {
  cidr_block = local.mumbai_vpc_cidr_block
  tags = {
    task = "instances"
    Name = "mumbai_vpc"
  }
}

# Gateways
resource "aws_internet_gateway" "mumbai_igw" {
  vpc_id = aws_vpc.mumbai_vpc.id
  tags = {
    task = "instances"
    Name = "mumbai_igw"
  }
}
resource "aws_eip" "public_eip" {
  domain = "vpc"
  tags = {
    task = "instances"
    Name = "public_eip"
  }
}
resource "aws_nat_gateway" "mumbai_ngw" {
  subnet_id     = aws_subnet.public_subnet.id
  allocation_id = aws_eip.public_eip.id
  tags = {
    task = "instances"
    Name = "mumbai_ngw"
  }
}

# Subnets
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.mumbai_vpc.id
  cidr_block              = local.public_subnet_cidr_block
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    task = "instances"
    Name = "public_subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.mumbai_vpc.id
  cidr_block = local.private_subnet_cidr_block
  tags = {
    task = "instances"
    Name = "private_subnet"
  }
}

# Route tables
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.mumbai_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mumbai_igw.id
  }
  tags = {
    task = "instances"
    Name = "public_route_table"
  }
}
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.mumbai_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.mumbai_ngw.id
  }
  tags = {
    task = "instances"
    Name = "private_route_table"
  }
}

# Attaching route tables with subnets
resource "aws_route_table_association" "public_rt_association" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet.id
}
resource "aws_route_table_association" "private_sn_association" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_subnet.id
}

# key pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "instance_key" {
  key_name   = "instance_key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}
resource "aws_secretsmanager_secret" "key_pair_secret" {
  name = "key_pair_secret"
}
resource "aws_secretsmanager_secret_version" "instance_key_version" {
  secret_string = tls_private_key.ssh_key.private_key_pem
  secret_id     = aws_secretsmanager_secret.key_pair_secret.id
}

# Creating Ec2 instances
resource "aws_instance" "public_instance" {
  ami             = local.ami_id
  instance_type   = local.instance_type
  subnet_id       = aws_subnet.public_subnet.id
  user_data       = file("user_data.sh")
  security_groups = [aws_security_group.public_instance_sg.id]
  key_name        = aws_key_pair.instance_key.key_name
  tags = {
    task = "instances"
    Name = "public_instance"
  }
}
resource "aws_instance" "private_instance" {
  ami             = local.ami_id
  instance_type   = local.instance_type
  subnet_id       = aws_subnet.private_subnet.id
  user_data       = file("user_data.sh")
  security_groups = [aws_security_group.private_instance_sg.id]
  key_name        = aws_key_pair.instance_key.key_name
  tags = {
    task = "instances"
    Name = "private_instance"
  }
}

# Security groups
resource "aws_security_group" "public_instance_sg" {
  name   = "public_instance_sg"
  vpc_id = aws_vpc.mumbai_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
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
    task = "instances"
    Name = "public_instance_sg"
  }
}
resource "aws_security_group" "private_instance_sg" {
  name   = "private_instance_sg"
  vpc_id = aws_vpc.mumbai_vpc.id
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
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    task = "instances"
    Name = "public_instance_sg"
  }
}