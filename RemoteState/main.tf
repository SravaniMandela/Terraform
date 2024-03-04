provider "aws"{
    region = "us-east-1"
}


resource "aws_s3_bucket" "s3"{
    bucket = "my-remote-state-1583" 
}

 resource "aws_instance" "ec2" {
    ami           = "ami-0cf10cdf9fcd62d37"
    instance_type = "t2.micro"
    tags = {
      Name = " EC2-B"
    }
 
  }

terraform{
    backend "s3"{
        bucket = "my-remote-state-1583"
        region = "us-east-1"
        key = "terraform.tfstate"
        encrypt = "false"
        profile = "beach"
        dynamodb_table = "dynamodb-terraform-state-lock"
    }
}