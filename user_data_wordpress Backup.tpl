#!/bin/bash

# Variables passed from Terraform
efs_mount_point="${efs_mount_point}"
db_password="${db_password}"
db_host="${db_host}"

# Define log file
log_file="/home/ubuntu/deployment.log"
exec > >(tee -a "$log_file") 2>&1

echo "[INFO] Updating packages..."
sudo apt update -y

echo "[INFO] Installing Docker, Docker Compose, and other utilities..."
sudo apt install -y docker.io docker-compose curl unzip apt-transport-https ca-certificates gnupg lsb-release

echo "[INFO] Enabling and starting Docker..."
sudo systemctl enable docker
sudo systemctl start docker

echo "[INFO] Adding user 'ubuntu' to docker group..."
sudo usermod -aG docker ubuntu

echo "[INFO] Setting SSH password for user 'ubuntu'..."
echo "ubuntu:${db_password}" | sudo chpasswd
sudo sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd

echo "[INFO] Creating application directories..."
mkdir -p /home/ubuntu/wordpress
mkdir -p /home/ubuntu/apache-php

echo "[INFO] Creating Dockerfile for WordPress..."
cat <<EOF > /home/ubuntu/wordpress/Dockerfile
FROM wordpress:latest
EXPOSE 80
EOF

echo "[INFO] Creating Dockerfile for Apache-PHP..."
cat <<EOF > /home/ubuntu/apache-php/Dockerfile
FROM php:8.0-apache
RUN docker-php-ext-install mysqli
RUN echo "ServerName portal.aws.cloud-people.net" >> /etc/apache2/apache2.conf
EOF

echo "[INFO] Creating docker-compose.yml..."
cat <<EOF > /home/ubuntu/docker-compose.yml
version: '3.3'
services:
  wordpress:
    build:
      context: ./wordpress
      dockerfile: Dockerfile
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: ${db_host}
      WORDPRESS_DB_USER: admin
      WORDPRESS_DB_PASSWORD: '${db_password}'
      WORDPRESS_DB_NAME: wordpress
    depends_on:
      - apache

  apache:
    build:
      context: ./apache-php
      dockerfile: Dockerfile
EOF

echo "[INFO] Fixing file ownerships..."
sudo chown -R ubuntu:ubuntu /home/ubuntu/wordpress /home/ubuntu/apache-php /home/ubuntu/docker-compose.yml

echo "[INFO] Running docker-compose..."
cd /home/ubuntu
sudo -u ubuntu docker-compose up -d

echo "[INFO] WordPress should now be deploying..."
echo "[INFO] Logs stored at: $log_file"
