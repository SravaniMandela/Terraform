resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "instance_key" {
  key_name   = "instance"
  public_key = tls_private_key.ssh_key.public_key_openssh
}
resource "aws_secretsmanager_secret" "key_pair_secret_new" {
  name = "key_pair_secret_new"
}
resource "aws_secretsmanager_secret_version" "instance_key_version" {
  secret_string = tls_private_key.ssh_key.private_key_pem
  secret_id     = aws_secretsmanager_secret.key_pair_secret_new.id
}
 
# resource "aws_instance" "ec2" {
#     ami           = "ami-0cf10cdf9fcd62d37"
#     instance_type = "t2.micro"
#     subnet_id     = aws_subnet.pub.id
#     security_groups = [aws_security_group.ALB_sg.id,aws_security_group.ec2_sg.id,aws_security_group.webserver_sg.id]
#     associate_public_ip_address = true
#     key_name      = aws_key_pair.instance_key.key_name
#     user_data = base64encode(file("userdata.sh"))
#     tags = {
#       Name = " EC2-A"
#     }

#     }

    resource "aws_instance" "ec2" {
    ami           = "ami-0cf10cdf9fcd62d37"
    instance_type = "t2.micro"
    subnet_id     = aws_subnet.pub.id
    security_groups = [aws_security_group.ec2_sg.id]
    associate_public_ip_address = true
    key_name      = aws_key_pair.instance_key.key_name
    tags = {
      Name = " EC2-public"
    }
    }


   resource "aws_instance" "ec2p2" {
    ami           = "ami-0cf10cdf9fcd62d37"
    instance_type = "t2.micro"
    subnet_id     = aws_subnet.private2.id
    security_groups = [aws_security_group.webserver_sg.id]
    key_name = aws_key_pair.instance_key.key_name
 iam_instance_profile = aws_iam_instance_profile.app-instance-profile.name
 
  
    user_data = <<-EOF
    #!/bin/bash
    sudo su
    yum update -y
    mkdir -p /var/www/html
    sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-0bc69eae47664510e.efs.us-east-1.amazonaws.com:/ /var/www/html

    sudo yum update -y
    sudo yum install -y httpd httpd-tools mod_ssl
    sudo systemctl enable httpd
    sudo systemctl start httpd

    # install php 7.4
    sudo amazon-linux-extras enable php7.4
    sudo yum clean metadata
    sudo yum install php php-common php-pear -y
    sudo yum install php-{cgi,curl,mbstring,gd,mysqlnd,gettext,json,xml,fpm,intl,zip} -y

    # install mysql 5.7
    sudo rpm -Uvh https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
    sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
    sudo yum install mysql-community-server -y
    sudo systemctl enable mysqld
    sudo systemctl start mysqld

    # set permissions
    sudo usermod -a -G apache ec2-user
    sudo chown -R ec2-user:apache /var/www
    sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
    sudo find /var/www -type f -exec sudo chmod 0664 {} \;
    sudo chown apache:apache -R /var/www/html

    # download wordpress files
    wget https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz
    sudo cp -r wordpress/* /var/www/html/

   # get the rds creds from the rds-master secret
    secret_value=$(aws secretsmanager get-secret-value --secret-id rds-master-creds --query SecretString --output text)
    db_host=$(echo $secret_value | jq -r '.host')
    db_username=$(echo $secret_value | jq -r '.username')
    db_password=$(echo $secret_value | jq -r '.password')
    db_name=$(echo $secret_value | jq -r '.dbname')
    
    # create the wp-config.php file
    sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
    wp_config_file="/var/www/html/wp-config.php"
    sudo sed -i "s/database_name_here/$db_name/" $wp_config_file
    sudo sed -i "s/username_here/$db_username/" $wp_config_file
    sudo sed -i "s/password_here/$db_password/" $wp_config_file
    sudo sed -i "s/localhost/$db_host/" $wp_config_file
    sudo service httpd restart

    EOF
   
    tags = {
      Name = " app-tier1"
    }
    }

   


    resource "aws_instance" "ec2p" {
    ami           = "ami-0cf10cdf9fcd62d37"
    instance_type = "t2.micro"
    subnet_id     = aws_subnet.private.id
    security_groups = [aws_security_group.webserver_sg.id]
    key_name      = aws_key_pair.instance_key.key_name
     iam_instance_profile = aws_iam_instance_profile.app-instance-profile.name
   user_data = <<-EOF
    #!/bin/bash
    sudo su
    yum update -y
    mkdir -p /var/www/html
    sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-0bc69eae47664510e.efs.us-east-1.amazonaws.com:/ /var/www/html

    sudo yum update -y
    sudo yum install -y httpd httpd-tools mod_ssl
    sudo systemctl enable httpd
    sudo systemctl start httpd

    # install php 7.4
    sudo amazon-linux-extras enable php7.4
    sudo yum clean metadata
    sudo yum install php php-common php-pear -y
    sudo yum install php-{cgi,curl,mbstring,gd,mysqlnd,gettext,json,xml,fpm,intl,zip} -y

    # install mysql 5.7
    sudo rpm -Uvh https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
    sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
    sudo yum install mysql-community-server -y
    sudo systemctl enable mysqld
    sudo systemctl start mysqld

    # set permissions
    sudo usermod -a -G apache ec2-user
    sudo chown -R ec2-user:apache /var/www
    sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
    sudo find /var/www -type f -exec sudo chmod 0664 {} \;
    sudo chown apache:apache -R /var/www/html

    # download wordpress files
    wget https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz
    sudo cp -r wordpress/* /var/www/html/

   # get the rds creds from the rds-master secret
    secret_value=$(aws secretsmanager get-secret-value --secret-id rds-master-creds --query SecretString --output text)
    db_host=$(echo $secret_value | jq -r '.host')
    db_username=$(echo $secret_value | jq -r '.username')
    db_password=$(echo $secret_value | jq -r '.password')
    db_name=$(echo $secret_value | jq -r '.dbname')
    
    # create the wp-config.php file
    sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
    wp_config_file="/var/www/html/wp-config.php"
    sudo sed -i "s/database_name_here/$db_name/" $wp_config_file
    sudo sed -i "s/username_here/$db_username/" $wp_config_file
    sudo sed -i "s/password_here/$db_password/" $wp_config_file
    sudo sed -i "s/localhost/$db_host/" $wp_config_file
    sudo service httpd restart

    EOF

    tags = {
      Name = " app-tier2"
    }
  }