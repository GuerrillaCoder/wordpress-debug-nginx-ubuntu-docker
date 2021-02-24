# wordpress-debug-nginx-ubuntu-docker

Xdebug port is set to 9090

```
version: "3.8"
services:

    db:
        image: mysql:5.7
        volumes:
            - db_data:/var/lib/mysql
        restart: unless-stopped
        environment:
            MYSQL_ROOT_PASSWORD: somewordpress
            MYSQL_DATABASE: wordpress
            MYSQL_USER: wordpress
            MYSQL_PASSWORD: wordpress
        ports:
            - "3156:3306"
    wordpress:
        image: digitalreach/wordpress-debug-nginx-ubuntu
        container_name: wordpress-debug-nginx-ubuntu
        ports: 
            - "5330:2222"
            - "5331:80"
        restart: unless-stopped
        depends_on: 
            - db
        volumes:
            - wp_data:/var/www/html
        environment: 
            SSH_PASSWORD: testing123
            WORDPRESS_DB_HOST: db:3306
            WORDPRESS_DB_USER: wordpress
            WORDPRESS_DB_PASSWORD: wordpress
            WORDPRESS_DB_NAME: wordpress
volumes:
    db_data: {}
    wp_data: {}
    ```
