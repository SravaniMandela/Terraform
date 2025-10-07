terraform {
  backend "s3" {
    bucket         = "handson-task-state-filess"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
  }
}