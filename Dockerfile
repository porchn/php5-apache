FROM php:5.6-apache
#MAINTAINER porchn <pichai.chin@gmail.com>

ENV TZ=Asia/Bangkok
# Set Server timezone.
RUN echo $TZ > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata
RUN mkdir -p /etc/apache2/ssl

RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y install build-essential apache2-utils

RUN apt-get -qqy update \
    && apt-get install -y libpng12-dev libjpeg-dev \
    && apt-get -y install re2c libmcrypt-dev \
    && apt-get -y install zlib1g-dev \
    && apt-get -y install libssl-dev libc-client2007e-dev libkrb5-dev \
    && apt-get -y install libcurl4-gnutls-dev \
    && apt-get -y install libxml2-dev libxslt-dev \
    && apt-get -y install libssl-dev \
    && apt-get -y install libcurl4-openssl-dev \
    && apt-get -y install libmagickwand-dev libmagickcore-dev

RUN docker-php-ext-install bcmath \
    && docker-php-ext-configure gd --with-jpeg-dir=/usr/lib \
    && docker-php-ext-install gd \
    && docker-php-ext-configure imap --with-imap-ssl --with-kerberos \
    && docker-php-ext-install imap \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install mcrypt \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install zip


# Extension
# RUN docker-php-ext-install mysqli mbstring opcache pdo_mysql

# Memcache
RUN apt-get install -y libmemcached11 libmemcachedutil2 build-essential libmemcached-dev libz-dev
RUN pecl install memcached-2.2.0
RUN docker-php-ext-enable memcached

#Imagick
RUN pecl install imagick
RUN docker-php-ext-enable imagick

# Defaul config php.ini
COPY ./config/php.ini /usr/local/etc/php/
COPY ./config/timezone.ini /usr/local/etc/php/conf.d/
COPY ./index.php /var/www/html/

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Enable ssl
RUN a2enmod ssl
RUN a2enmod headers

# Create Volume
VOLUME ['var/www/html']

EXPOSE 80 443