FROM ubuntu:22.04

ENV DEBUG_IP=host.docker.internal
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/London

RUN apt-get update -y && apt-get install -y apt-utils dialog lsb-release gnupg2 dirmngr ca-certificates apt-transport-https software-properties-common

RUN add-apt-repository ppa:ondrej/php -y

RUN apt-get update -y && apt-get install -y supervisor php8.1-fpm php8.1-cli php8.1-common  htop openssh-server libxml2-dev libmemcached-tools \
    memcached zlib1g-dev libpq-dev libmemcached-dev vim nginx php8.1-memcached php8.1-soap curl zip unzip php8.1-curl \
    php8.1-dom php8.1-gd php8.1-mbstring php8.1-mysql php8.1-xml php8.1-imagick php8.1-ssh2 php8.1-exif php8.1-xdebug htop php-pear php-dev

#RUN pecl channel-update pecl.php.net && pecl install xdebug

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

RUN echo 'Port 			2222\n\
ListenAddress 		0.0.0.0\n\
LoginGraceTime 		180\n\
X11Forwarding 		yes\n\
Ciphers aes128-cbc,3des-cbc,aes256-cbc,aes128-ctr,aes192-ctr,aes256-ctr\n\
MACs hmac-sha1,hmac-sha1-96\n\
StrictModes 		yes\n\
SyslogFacility 		DAEMON\n\
PasswordAuthentication 	yes\n\
PermitEmptyPasswords 	no\n\
PermitRootLogin 	yes\n\
Subsystem sftp internal-sftp\n\
AllowUsers www-data root' > /etc/ssh/sshd_config

RUN chsh -s /bin/bash www-data

EXPOSE 2222
EXPOSE 443

COPY memcached/memcached.conf /etc/memcached.conf
COPY php/ /etc/php/

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY nginx/default /etc/nginx/sites-available/

COPY wp-init-new.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/wp-init-new.sh

COPY wp-config-docker.php /var/www/html/

VOLUME /var/www/html

# ENTRYPOINT /usr/local/bin/wp-debug-init.sh php-fpm
# ENTRYPOINT /usr/local/bin/wp-init.sh && tail -f /dev/null
ENTRYPOINT /usr/local/bin/wp-init-new.sh && /usr/bin/supervisord
