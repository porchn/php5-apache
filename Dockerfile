FROM php:5.6-apache
#MAINTAINER porchn <pichai.chin@gmail.com>

ENV TZ=Asia/Bangkok
# Set Server timezone.
RUN echo $TZ > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata
RUN mkdir -p /etc/apache2/ssl

RUN echo date.timezone = $TZ > /usr/local/etc/php/conf.d/docker-php-ext-timezone.ini
# Defaul config php.ini
COPY ./config/php.ini /usr/local/etc/php/
COPY ./index.php /var/www/html/

# RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y update
RUN apt-get -y install libmemcached11 libmemcachedutil2 libmemcached-dev libz-dev \
    && apt-get -y install build-essential apache2-utils \
    && apt-get -y install libmagickwand-dev imagemagick \
    && apt-get -y install libcurl4-openssl-dev \
    && apt-get -y install libssl-dev libc-client2007e-dev libkrb5-dev \
    && apt-get -y install libmcrypt-dev \
    && rm -rf /var/lib/apt/lists/*

# Config Extension 
RUN docker-php-ext-configure gd --with-jpeg-dir=/usr/lib \
    && docker-php-ext-configure imap --with-imap-ssl --with-kerberos 

# Install Extension mysqli mysql mbstring opcache pdo_mysql gd mcrypt zip imap bcmath soap
RUN docker-php-ext-install mysqli mysql mbstring opcache pdo_mysql gd mcrypt zip imap soap

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Enable ssl
RUN a2enmod ssl
RUN a2enmod headers

# Memcache
RUN pecl install memcached-2.2.0
RUN docker-php-ext-enable memcached

# Imagick
RUN pecl install imagick
RUN docker-php-ext-enable imagick
RUN chown -R www-data:www-data /var/www

# Create Volume
VOLUME ['/etc/apache2/sites-enabled','/var/www','/var/log/apache2']

EXPOSE 80
EXPOSE 443