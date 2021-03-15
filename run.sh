#!/bin/bash

#If EspoCRM is not installed, we need to install it
if [ -z "$(ls -A /var/www/espocrm)" ]
then
    echo "EspoCRM not installed. Installing..."

    wget https://www.espocrm.com/downloads/EspoCRM-6.1.4.zip -O /tmp/espocrm.zip
    unzip /tmp/espocrm.zip -d /tmp/espocrm
    mv /tmp/espocrm/EspoCRM-6.1.4/* /var/www/espocrm

    cd /var/www/espocrm
    chown -R www-data:www-data /var/www/espocrm
    find . -type d -exec chmod 755 {} + && find . -type f -exec chmod 644 {} +;
    find data custom client/custom -type d -exec chmod 775 {} + && find data custom client/custom -type f -exec chmod 664 {} +;
    chmod 775 application/Espo/Modules client/modules;

    echo "EspoCRM is now installed."
else
    echo "EspoCRM is already installed. Continueing"
fi

echo "Running preflight configuration..."

#Create the files and folders required for PHP FPM
mkdir -p /run/php/
touch /run/php/php7.4-fpm.sock
mkdir -p /var/log/php-fpm

# Set permissions
chown -R www-data:www-data /var/www/
chmod -R u+rw /var/www 

#Configure php.ini
sed -i 's/max_execution_time = .*/max_execution_time = 180/g' /etc/php/7.4/fpm/php.ini
sed -i 's/max_input_time = .*/max_input_time = 180/g' /etc/php/7.4/fpm/php.ini
sed -i 's/post_max_size = .*/post_max_size = 20M/g' /etc/php/7.4/fpm/php.ini
sed -i 's/memory_limit = .*/memory_limit = 256M/g' /etc/php/7.4/fpm/php.ini
sed -i 's/upload_max_filesize = .*/upload_max_filesize = 20M/g' /etc/php/7.4/fpm/php.ini

echo "Configuration complete"

/usr/bin/supervisord -n -c /app/supervisord.conf