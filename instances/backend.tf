terraform {
  backend "s3" {
    bucket         = "instance-task-state-files"
    key            = "terraform.tfstate"
    dynamodb_table = "instance_task_state_file_lock"
    region         = "ap-south-1"
  }
}