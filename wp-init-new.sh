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

wpEnvs=( "${!WORDPRESS_@}" )
	if [ ! -s wp-config.php ] && [ "${#wpEnvs[@]}" -gt 0 ]; then
		for wpConfigDocker in \
			wp-config-docker.php \
			/var/www/html/wp-config-docker.php \
		; do
			if [ -s "$wpConfigDocker" ]; then
				echo >&2 "No 'wp-config.php' found in $PWD, but 'WORDPRESS_...' variables supplied; copying '$wpConfigDocker' (${wpEnvs[*]})"
				# using "awk" to replace all instances of "put your unique phrase here" with a properly unique string (for AUTH_KEY and friends to have safe defaults if they aren't specified with environment variables)
				awk '
					/put your unique phrase here/ {
						cmd = "head -c1m /dev/urandom | sha1sum | cut -d\\  -f1"
						cmd | getline str
						close(cmd)
						gsub("put your unique phrase here", str)
					}
					{ print }
				' "$wpConfigDocker" > wp-config.php
				chown www-data:www-data wp-config.php
				break
			fi
		done
	fi



#CONFIG=/var/www/html/wp-config.php
#if [ ! -f "$CONFIG" ]; then
#    echo "Adding config fron env vars..."
#    wp config create --path=/var/www/html --allow-root \
#    --dbname=$WORDPRESS_DB_NAME --dbuser=$WORDPRESS_DB_USER --dbpass=$WORDPRESS_DB_PASSWORD --dbhost=$WORDPRESS_DB_HOST --skip-check \
#    --extra-php <<PHP
#define( 'WP_DEBUG', true );
#define( 'WP_DEBUG_LOG', true );
#define( 'ALTERNATE_WP_CRON', true );
#PHP
#    chown -R www-data:www-data /var/www/html
#fi


echo "root:$SSH_PASSWORD" | chpasswd
echo "www-data:$SSH_PASSWORD" | chpasswd
