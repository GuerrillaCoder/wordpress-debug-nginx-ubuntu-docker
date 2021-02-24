#!/bin/bash


PHPDIR=/var/run/php
if [ ! -d "$PHPDIR" ]; then
    echo "Making PHP process directory..."
    mkdir /var/run/php/
fi

SSHDIR=/run/sshd
if [ ! -d "$SSHDIR" ]; then
    echo "Making SSH process directory..."
    mkdir /run/sshd/
fi

INDEX=/var/www/html/index.php
if [ ! -f "$INDEX" ]; then
    echo "Downloading wordpress..."
    wp core download --path=/var/www/html --allow-root
    chown -R www-data:www-data /var/www/html
fi

CONFIG=/var/www/html/wp-config.php
if [ ! -f "$CONFIG" ]; then
    echo "Adding config fron env vars..."
    wp config create --path=/var/www/html --allow-root \
    --dbname=$WORDPRESS_DB_NAME --dbuser=$WORDPRESS_DB_USER --dbpass=$WORDPRESS_DB_PASSWORD --dbhost=$WORDPRESS_DB_HOST --skip-check \
    --extra-php <<PHP
define( 'WP_DEBUG', true );
define( 'WP_DEBUG_LOG', true );
define( 'ALTERNATE_WP_CRON', true );
PHP
    chown -R www-data:www-data /var/www/html
fi


echo "root:$SSH_PASSWORD" | chpasswd
echo "www-data:$SSH_PASSWORD" | chpasswd