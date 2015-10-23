# FROM php:5.6-apache
FROM octohost/php5:5.5

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
    && docker-php-ext-install iconv mcrypt pdo mysql pdo_mysql mbstring soap gd

# Get PrestaShop
#ADD https://www.prestashop.com/download/old/prestashop_1.6.1.1.zip /tmp/prestashop.zip
ADD https://www.prestashop.com/ajax/controller.php?method=download&type=releases&file=prestashop_1.6.1.1.zip&language=fr /tmp/prestashop.zip
RUN unzip -q /tmp/prestashop.zip -d /tmp/
RUN cp -R /tmp/prestashop/* /var/www/html

RUN rm -R /var/www/html/install
RUN mv /var/www/html/admin /var/www/html/admin-pa28

#Install APC
RUN pear config-set php_ini /usr/local/etc/php/php.ini
RUN pecl config-set php_ini /usr/local/etc/php/php.ini
RUN pecl install apcu-beta \
    && echo extension=apcu.so > /usr/local/etc/php/conf.d/apcu.ini

#PHP Limits
ADD php-limits.ini /usr/local/etc/php/conf.d/php-limits.ini

#ADD https://github.com/PrestaShop/docker/blob/master/config_files/docker_updt_ps_domains.php /var/www/html/

# Apache configuration
RUN a2enmod rewrite
RUN chown www-data:www-data -R /var/www/html/

# PHP configuration
ADD https://github.com/PrestaShop/docker/blob/master/config_files/php.ini /usr/local/etc/php/

COPY settings.inc.php /var/www/html/config/settings.inc.php



VOLUME /var/www/html/modules
VOLUME /var/www/html/themes
VOLUME /var/www/html/override
VOLUME /var/www/html/img
VOLUME /var/www/html/mails
VOLUME /var/www/html/translations

#COPY config_files/docker_run.sh /tmp/

#CMD ["apache2-foreground"]
CMD service php5-fpm start && nginx
