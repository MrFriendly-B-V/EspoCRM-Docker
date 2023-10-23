FROM ubuntu:jammy

ARG DEBIAN_FRONTEND=noninteractive

# Update
RUN apt-get update -y

#Install required dependencies
RUN apt-get install -y --no-install-recommends \
        php8.1 \
        php8.1-mysql \
        php-json \
        php8.1-gd \
        php8.1-zip \
        php8.1-imap  \
        php8.1-mbstring \
        php8.1-curl \
        php8.1-exif \
        php8.1-xml \ 
        php8.1-xmlwriter \
        php8.1-posix \
        php8.1-zmq \
        php8.1-fpm \
        nginx \
        wget \
        unzip \
        cron \
        libpcre2-8-0 \
        supervisor

#Enable PHP modules
RUN phpenmod imap mbstring

#Crontab
RUN crontab -l | { cat; echo "* * * * * cd /var/www/espocrm; /usr/bin/php -f cron.php > /dev/null 2>&1"; } | crontab -

#Delete default nginx configs
RUN rm -rf /etc/nginx/sites-available/*
RUN rm -rf /etc/nginx/sites-enabled/*

#Copy in our nginx config and symlink it
COPY ./espocrm.conf /etc/nginx/sites-available/espocrm.conf 
RUN ln -s /etc/nginx/sites-available/espocrm.conf /etc/nginx/sites-enabled/espocrm.conf

#Copy in our script and the supervisord configuration file
COPY ./run.sh /app/run.sh
COPY ./supervisord.conf /app/supervisord.conf

EXPOSE 80
ENTRYPOINT ["sh", "-c", "/app/run.sh"]