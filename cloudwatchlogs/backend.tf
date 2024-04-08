terraform {
  backend "s3" {
    bucket         = "cloudwatch-task-state-files"
    key            = "ALB/terraform.tfstate"
    dynamodb_table = "cloudwatch_task_state_file_lock"
    region         = "us-east-1"
  }
}