#!/bin/bash

yum update -y
yum install httpd -y
systemctl start httpd.service
systemctl enable httpd.service
echo "<html><body><h1>Hello World from $(hostname -f)</h1></body></html>" > /var/www/html/index.html
echo "configured successfully ...!"