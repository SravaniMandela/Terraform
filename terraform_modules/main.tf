provider "aws" {
  region = "us-east-1"
}

module "s3_bucket" {
  source       = "./modules/s3"
  bucket_name  = "my-terraform-demo-bucket-123"
  tags = {
    Environment = "dev"
  }
}