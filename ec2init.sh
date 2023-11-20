#!/bin/bash

# setup swap
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo swapon -s
echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab

# install httpd, db connection, php, and git
sudo dnf update -y

# install httpd and mod ssl
sudo dnf install -y httpd wget php-fpm php-mysqli php-json php php-devel php-mbstring php-simplexml php-gd php-opcache php-bcmath php-pear git
sudo dnf install -y mod_ssl

# install mysql client
sudo dnf install -y mariadb105-server

# install required dependencies for Sodium encryption library
sudo dnf install -y gcc
wget https://download.libsodium.org/libsodium/releases/LATEST.tar.gz
tar -xvzf LATEST.tar.gz
cd libsodium-stable
./configure
make && make check
#install sodium encryption package
sudo make install
sudo pecl install -f libsodium
# add sodium extension to php.d
echo "extension=sodium.so" | sudo tee /etc/php.d/sodium.ini

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

# set folder/file permissions
sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;

# install kyte utility gust
cd ~
git clone https://github.com/keyqcloud/gust.git
sudo ln -s ~/gust/gust.php /usr/local/bin/gust
sudo ln -s /usr/local/bin/gust /usr/bin/gust

#setup gust
gust /var/www/html/ InnoDB utf8mb4

KYTE_ACCOUNT_PASSWORD=$(LC_ALL=C tr -dc 'A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~' </dev/urandom | head -c 13 ; echo)
echo $KYTE_ACCOUNT_PASSWORD > ~/kyte_password
# gust init account admin Administrator user@example.com $KYTE_ACCOUNT_PASSWORD

# reboot instance
sudo reboot
