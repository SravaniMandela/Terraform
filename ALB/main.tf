resource "aws_vpc" "virginia_vpc" {
  cidr_block = local.virginia_vpc_cidr_block
  tags = {
    task = "ALB"
    Name = "virginia_vpc"
  }
}

# Gateways
resource "aws_internet_gateway" "virginia_igw" {
  vpc_id = aws_vpc.virginia_vpc.id
  tags = {
    task = "ALB"
    Name = "virginia_igw"
  }
}


# Subnets
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.virginia_vpc.id
  cidr_block              = local.public_subnet_cidr_block
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    task = "ALB"
    Name = "public_subnet"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.virginia_vpc.id
  cidr_block              = local.public_subnet_cidr_block_2
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    task = "ALB"
    Name = "public_subnet_2"
  }
}

# Subnets

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.virginia_vpc.id
  cidr_block = local.private_subnet_cidr_block
  availability_zone = "us-east-1a"
  tags = {
    task = "ALB"
    Name = "private_subnet"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id     = aws_vpc.virginia_vpc.id
  cidr_block = local.private_subnet_cidr_block_2
  availability_zone = "us-east-1b"
  tags = {
    task = "ALB"
    Name = "private_subnet_2"
  }
}
# Route tables
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.virginia_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.virginia_igw.id
  }
  tags = {
    task = "ALB"
    Name = "public_route_table"
  }
}
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.virginia_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.virginia_ngw.id
  }
  tags = {
    task = "ALB"
    Name = "private_route_table"
  }
}

#nat gateway
resource "aws_eip" "public_eip" {
  domain = "vpc"
  tags = {
    task = "ALB"
    Name = "public_eip"
  }
}
resource "aws_nat_gateway" "virginia_ngw" {
  subnet_id     = aws_subnet.public_subnet.id
  allocation_id = aws_eip.public_eip.id
  tags = {
    task = "ALB"
    Name = "virginia_ngw"
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
resource "aws_route_table_association" "private_sn_association2" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_subnet_2.id
}