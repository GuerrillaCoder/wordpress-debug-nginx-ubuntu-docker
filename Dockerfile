FROM ubuntu:20.04

ENV DEBUG_IP=host.docker.internal
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/London

RUN apt-get update && apt-get install -y supervisor php7.4-fpm htop openssh-server libxml2-dev libmemcached-tools \
    memcached zlib1g-dev libpq-dev libmemcached-dev vim nginx php-memcached php-soap curl zip unzip php-curl \
    php-dom php-gd php-mbstring php-mysql php-xml php-imagick php-ssh2 php-exif php-xdebug htop

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

VOLUME /var/www/html

# ENTRYPOINT /usr/local/bin/wp-debug-init.sh php-fpm
# ENTRYPOINT /usr/local/bin/wp-init.sh && tail -f /dev/null
ENTRYPOINT /usr/local/bin/wp-init.sh && /usr/bin/supervisord