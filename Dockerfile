FROM php:5.6-apache

MAINTAINER Jean Baptsite Marchetti <marchetti.jb@gmail.com>


# Avoid MySQL questions during installation
ENV DEBIAN_FRONTEND noninteractive
RUN echo mysql-server-5.6 mysql-server/root_password password $DB_PASSWD | debconf-set-selections
RUN echo mysql-server-5.6 mysql-server/root_password_again password $DB_PASSWD | debconf-set-selections

RUN apt-get update \
	&& apt-get install -y libmcrypt-dev \
		libjpeg62-turbo-dev \
		libpng12-dev \
		libfreetype6-dev \
		libxml2-dev \
		mysql-client \
		mysql-server \
		wget \
		unzip \
    memcached \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install iconv mcrypt pdo mysql pdo_mysql mbstring soap gd && \
    pecl install apc

# Get PrestaShop
ADD https://www.prestashop.com/ajax/controller.php?method=download&type=releases&file=prestashop_1.6.1.1.zip&language=en /tmp/prestashop.zip
RUN unzip -q /tmp/prestashop.zip -d /tmp/
RUN cp -R /tmp/prestashop/* /var/www/html

RUN rm -R /var/www/html/install
RUN mv /var/www/html/admin /var/www/html/admin-pa28

#ADD https://github.com/PrestaShop/docker/blob/master/config_files/docker_updt_ps_domains.php /var/www/html/

# Apache configuration
RUN a2enmod rewrite
RUN chown www-data:www-data -R /var/www/html/

# PHP configuration
ADD https://github.com/PrestaShop/docker/blob/master/config_files/php.ini /usr/local/etc/php/
#RUN echo 'extension=apc.so' >> /usr/local/etc/php/php.ini && \
#    echo 'extension=memcache.so' >> /usr/local/etc/php/php.ini && \


COPY settings.inc.php /var/www/html/config/settings.inc.php

# MySQL configuration
# RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
# EXPOSE 3306

VOLUME /var/www/html/modules
VOLUME /var/www/html/themes
VOLUME /var/www/html/override
VOLUME /var/www/html/img

#COPY config_files/docker_run.sh /tmp/

ENTRYPOINT ["/usr/sbin/apache2ctl -D FOREGROUND"]
