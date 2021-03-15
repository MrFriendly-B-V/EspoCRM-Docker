FROM ubuntu

ARG DEBIAN_FRONTEND=noninteractive

#Update and required dependency for adding a repository
RUN apt-get update -y
RUN apt-get install -y software-properties-common

#Add the PHP repository and update
RUN add-apt-repository -y ppa:ondrej/php
RUN apt-get update -y

#Install required dependencies
RUN apt-get install -y --no-install-recommends \
        php7.4 \
        php7.4-mysql \
        php7.4-json \
        php7.4-gd \
        php7.4-zip \
        php7.4-imap  \
        php7.4-mbstring \
        php7.4-curl \
        php7.4-exif \
        php7.4-xml \ 
        php7.4-xmlwriter \
        php7.4-posix \
        php7.4-zmq \
        php7.4-fpm \
        nginx \
        wget \
        unzip \
        cron \
        supervisor

#Enable PHP modules
RUN phpenmod imap mbstring

#Crontab
RUN echo "$(echo '* * * * * /usr/bin/php -f /var/www/espocrm/cron.php > /dev/null 2>&1' ; crontab -u root -l)" | crontab -u root -

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