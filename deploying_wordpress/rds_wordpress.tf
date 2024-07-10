resource "aws_db_subnet_group" "rds_subnets" {
  name = "rds_subnet_groups"
  subnet_ids = [aws_subnet.private3.id, aws_subnet.private4.id]
  

  tags = {
    Name = "My DB subnet group"
  }
}

resource "random_password" "master-password" {
  length = 10
  special = false
}
 
 resource "aws_db_instance" "rds" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  storage_type         = "gp2"
  db_name              = local.rds_db_name
  username             = local.rds_user_name
  identifier           = local.rds_name
  password             = random_password.master-password.result
  db_subnet_group_name = aws_db_subnet_group.rds_subnets.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot =  true
  tags = {
    Name= "wordpress-rds"
  }
}

resource "aws_secretsmanager_secret" "rds-master-creds" {
  name = "rds-master-creds"
}

resource "aws_secretsmanager_secret_version" "rds-master-secret" {
  secret_id     = aws_secretsmanager_secret.rds-master-creds.id
  secret_string = <<EOF
  {
    "host": "${substr(aws_db_instance.rds.endpoint, 0, length(aws_db_instance.rds.endpoint) - length(":${aws_db_instance.rds.port}"))}",
    "port": "${aws_db_instance.rds.port}",
    "username": "${local.rds_user_name}",
    "password": "${random_password.master-password.result}",
    "dbname": "${local.rds_db_name}"
  }
  EOF
}

resource "aws_efs_file_system" "efs" {
  creation_token = "EFS"
  encrypted = false
  tags = {
    Name = "EFS"
  }
}

resource "aws_efs_mount_target" "mount_target_a" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.private3.id
  security_groups = [aws_security_group.EFS_sg.id]
}

resource "aws_efs_mount_target" "mount_target_b" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.private4.id
  security_groups = [aws_security_group.EFS_sg.id]
}
