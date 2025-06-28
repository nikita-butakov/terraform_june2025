#!/bin/bash
yum update -y
yum install -y nginx
systemctl enable nginx
systemctl start nginx
echo "Backend Server" > /usr/share/nginx/html/index.html

