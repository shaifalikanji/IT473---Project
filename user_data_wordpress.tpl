#!/bin/bash

# Log everything to a file for debugging
exec > /var/log/user-data.log 2>&1

# Variables from Terraform
efs_mount_point="${efs_mount_point}"
db_name="${db_name}"
db_user="${db_user}"
db_password="${db_password}"
db_host="${db_host}"

# Update and install dependencies
apt update -y
apt install -y apache2 php php-mysql libapache2-mod-php wget unzip curl less mariadb-client

# Clean default Apache index.html
rm -f /var/www/html/index.html

# Download and set up WordPress
cd /var/www/html
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -r wordpress/* .
rm -rf wordpress latest.tar.gz

# Create wp-config.php
cp wp-config-sample.php wp-config.php
sed -i "s/database_name_here/${db_name}/" wp-config.php
sed -i "s/username_here/${db_user}/" wp-config.php
sed -i "s/password_here/${db_password}/" wp-config.php
sed -i "s/localhost/${db_host}/" wp-config.php

# Inject HTTPS fix for ALB (before "stop editing" line)
sed -i "/Happy publishing/i\\
// Handle HTTPS behind ALB or reverse proxy\\
if (isset(\$_SERVER['HTTP_X_FORWARDED_PROTO']) && \$_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {\\
    \$_SERVER['HTTPS'] = 'on';\\
}" wp-config.php

# Set file permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Install WP-CLI
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

# Run WordPress install (automated)
sudo -u www-data wp core install \
  --url="https://www.aws.cloud-people.net/" \
  --title="IT473 – Bachelor’s Capstone  Group 4" \
  --admin_user="admin" \
  --admin_password="${db_password}" \
  --admin_email="ahmedbedair@student.purdueglobal.edu" \
  --skip-email \
  --path=/var/www/html

# Enable and start Apache
systemctl enable apache2
systemctl start apache2
