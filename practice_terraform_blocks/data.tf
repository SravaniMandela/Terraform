data "aws_ami" "amazon_linux_2" {
  owners      = ["amazon"]
  most_recent = true
  
  # Filter to find the Amazon Linux 2 (x86_64, EBS backed)
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}