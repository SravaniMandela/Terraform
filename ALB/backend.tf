terraform {
  backend "s3" {
    bucket         = "handson-task-state-files"
    key            = "ALB/terraform.tfstate"
    dynamodb_table = "handson_task_state_file_lock"
    region         = "us-east-1"
  }
}