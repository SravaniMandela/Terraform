terraform {
  backend "s3" {
    bucket = "bucket-vpc-lock"
    key    = "terraform.tfstate"
    region = "us-east-1"
    dynamodb_table="bucket-vpc-lock-table"
  }
}
