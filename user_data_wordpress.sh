#!/bin/bash
yum update -y
amazon-linux-extras install -y php7.4
yum install -y httpd php php-mysqlnd

mkdir -p /mnt/efs
mount -t nfs4 -o nfsvers=4.1 ${efs_mount_point}:/ /mnt/efs

echo "<?php phpinfo(); ?>" > /var/www/html/index.php

systemctl enable httpd
systemctl start httpd
