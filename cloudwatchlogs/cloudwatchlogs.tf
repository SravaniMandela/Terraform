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

#creating policy
resource "aws_iam_policy" "policy" {
  name        = "cloudwatch_logs"
  description = "cloudwatch_logs"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        Resource = ["arn:aws:logs:*:*:*"]
      }
    ]
  })
}

#creating role
resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

#attach role and policy
resource "aws_iam_role_policy_attachment" "attachment" {
  policy_arn = aws_iam_policy.policy.arn
  role       = aws_iam_role.ec2_role.name
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "instance_key" {
  key_name   = "instance_key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}
resource "aws_secretsmanager_secret" "key_pair_secret" {
  name = "key_pair_secret_id"
}
resource "aws_secretsmanager_secret_version" "instance_key_version" {
  secret_string = tls_private_key.ssh_key.private_key_pem
  secret_id     = aws_secretsmanager_secret.key_pair_secret.id
}


resource "aws_subnet" "pub" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.100.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "VPC-A-Public"
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

 resource "aws_route_table_association" "a" {
    subnet_id      = aws_subnet.pub.id
    route_table_id = aws_route_table.rt1.id
  }

resource "aws_instance" "ec2" {
  ami                         = "ami-0cf10cdf9fcd62d37"
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.sg.id]
  key_name                    = aws_key_pair.instance_key.key_name
  subnet_id                   = aws_subnet.pub.id
  associate_public_ip_address = true
  tags = {
    Name = " EC2-A"
  }
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

}

#attach role to ec2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_role.name
}


resource "aws_security_group" "sg" {
  name = "first-sg"

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