#!/bin/bash

# setup swap
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo swapon -s
echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab

# install httpd, db connection, php, and git
sudo yum update -y

# install httpd and mod ssl
sudo yum install -y httpd
sudo yum install -y mod_ssl

# install git
sudo yum install -y git

#8.0
sudo amazon-linux-extras install -y php8.0
sudo yum clean metadata
sudo yum install -y php php-mbstring php-simplexml php-gd php-mysqli php-opcache

# install composer
cd ~
sudo curl -sS https://getcomposer.org/installer | sudo php
sudo mv composer.phar /usr/local/bin/composer
sudo ln -s /usr/local/bin/composer /usr/bin/composer

# allow overrides for /var/www/html
sudo sed -i '/<Directory "\/var\/www\/html">/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf

# enable http and set group ownership and membership
sudo systemctl enable httpd
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www

# install kyte boiler plate
git clone https://github.com/keyqcloud/kyte.git /var/www/html

# create base folders
mkdir /var/www/html/app
mkdir /var/www/html/app/models
mkdir /var/www/html/app/controllers

# set folder/file permissions
sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;

# install dependencies
cd /var/www/html
composer install

# install kyte utility gust
cd ~
git clone https://github.com/keyqcloud/gust.git
sudo ln -s ~/gust/gust.php /usr/local/bin/gust
sudo ln -s /usr/local/bin/gust /usr/bin/gust

#setup gust
gust /var/www/html/ InnoDB utf8mb4

# reboot instance
sudo reboot
