FROM prestashop/prestashop:latest

MAINTAINER Jean Baptsite Marchetti <marchetti.jb@gmail.com>

RUN apt-get update && \
    apt-get install -y php5-curl php5-memcache memcached php-pear build-essential php5-tidy php5-curl apache2-dev php5-mcrypt php5-json git-core && apt-get clean && \
    pecl install apc && \
    echo 'extension=apc.so' >> /usr/local/etc/php/php.ini && \
    echo 'extension=memcache.so' >> /usr/local/etc/php/php.ini && \
    a2enmod expires && \
    a2enmod headers && \
    php5enmod mcrypt

RUN mv /var/www/html/admin-dev /var/www/html/admin-pa28
RUN rm -R /var/www/html/install-dev
COPY settings.inc.php /var/www/html/config/settings.inc.php


ENTRYPOINT ["/tmp/docker_run.sh"]
