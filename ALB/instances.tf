resource "aws_instance" "private_instance" {
  ami             = local.ami_id
  instance_type   = local.instance_type
  subnet_id       = aws_subnet.private_subnet.id
  user_data       = file("user_data.sh")
  security_groups = [aws_security_group.private_instance_sg.id]
  tags = {
    task = "ALB"
    Name = "private_instance"
  }
}

resource "aws_instance" "private_instance_2" {
  ami             = local.ami_id
  instance_type   = local.instance_type
  subnet_id       = aws_subnet.private_subnet_2.id
  user_data       = file("user_data.sh")
  security_groups = [aws_security_group.private_instance_sg.id]
  tags = {
    task = "ALB"
    Name = "private_instance_2"
  }
}

resource "aws_security_group" "private_instance_sg" {
  name   = "private_instance_sg"
  vpc_id = aws_vpc.virginia_vpc.id
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [local.public_subnet_cidr_block]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    task = "ALB"
    Name = "public_instance_sg"
  }
}