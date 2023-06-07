FROM ubuntu:22.04

ENV DEBUG_IP=host.docker.internal
ARG DEBIAN_FRONTEND=noninteractivegi
ENV TZ=Europe/London

RUN apt-get update -y && apt-get install -y apt-utils lsb-release gnupg2 dirmngr ca-certificates apt-transport-https software-properties-common

RUN add-apt-repository ppa:ondrej/php -y

RUN apt-get update -y && apt-get install -y supervisor php8.2-fpm php8.2-cli php8.2-common  htop openssh-server libxml2-dev libmemcached-tools \
    memcached zlib1g-dev libpq-dev libmemcached-dev vim nginx php8.2-memcached php8.2-soap curl zip unzip php8.2-curl \
    php8.2-dom php8.2-gd php8.2-mbstring php8.2-mysql php8.2-xml php8.2-imagick php8.2-ssh2 php8.2-exif htop php-pear php-dev

RUN pecl channel-update pecl.php.net && pecl install xdebug

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

COPY wp-init.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/wp-init.sh

COPY wp-config-docker.php /var/www/html/

VOLUME /var/www/html

# ENTRYPOINT /usr/local/bin/wp-debug-init.sh php-fpm
# ENTRYPOINT /usr/local/bin/wp-init.sh && tail -f /dev/null
ENTRYPOINT /usr/local/bin/wp-init-new.sh && /usr/bin/supervisord
