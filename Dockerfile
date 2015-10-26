# Starting point is latest ubuntu image
FROM debian:jessie

MAINTAINER Jean Baptsite Marchetti <marchetti.jb@gmail.com>

#Set up latest sources for apt-get
# persistent / runtime deps
RUN apt-get update && apt-get install -y ca-certificates curl librecode0 libsqlite3-0 libxml2 --no-install-recommends && rm -r /var/lib/apt/lists/*

# phpize deps
RUN apt-get update && apt-get install -y autoconf file g++ gcc libc-dev make pkg-config re2c --no-install-recommends && rm -r /var/lib/apt/lists/*

# Surpress Upstart errors/warning
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl


# Avoid MySQL questions during installation
ENV DEBIAN_FRONTEND noninteractive
RUN echo mysql-server-5.6 mysql-server/root_password password $DB_PASSWD | debconf-set-selections
RUN echo mysql-server-5.6 mysql-server/root_password_again password $DB_PASSWD | debconf-set-selections


#Update and upgrade ubuntu
RUN apt-get update
RUN apt-get -y upgrade


# Basic Requirements
RUN apt-get -y install mysql-server mysql-client vim nginx php5-fpm php5-mysql php-apc pwgen python-setuptools curl git unzip

# Prestaship Requirements
RUN apt-get -y install php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcache php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl


# nginx config
RUN sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf
# since 'upload_max_filesize = 2M' in /etc/php5/fpm/php.ini
RUN sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 3m/" /etc/nginx/nginx.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# php-fpm config
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
RUN find /etc/php5/cli/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;
RUN sed -i 's/^;clear_env = no/clear_env = no/g' /etc/php5/fpm/pool.d/www.conf

# nginx site conf
ADD ./nginx-site.conf /etc/nginx/sites-available/default

# Supervisor Config
RUN /usr/bin/easy_install supervisor
ADD ./supervisord.conf /etc/supervisord.conf



# Get PrestaShop
#ADD https://www.prestashop.com/download/old/prestashop_1.6.1.1.zip /tmp/prestashop.zip
ADD https://www.prestashop.com/ajax/controller.php?method=download&type=releases&file=prestashop_1.6.1.1.zip&language=fr /tmp/prestashop.zip
RUN unzip -q /tmp/prestashop.zip -d /tmp/
RUN cp -R /tmp/prestashop/* /var/www/html
RUN rm -R /var/www/html/install
RUN mv /var/www/html/admin /var/www/html/admin-pa28
RUN chown -R www-data:www-data /var/www/html

#Prestashop configuration
COPY settings.inc.php /var/www/html/config/settings.inc.php


#ADD https://github.com/PrestaShop/docker/blob/master/config_files/docker_updt_ps_domains.php /var/www/html/

VOLUME /var/www/html/modules
VOLUME /var/www/html/themes
VOLUME /var/www/html/override
VOLUME /var/www/html/img
VOLUME /var/www/html/mails
VOLUME /var/www/html/translations

# Prestashop Initialization and Startup Script
ADD ./start.sh /start.sh
RUN chmod 755 /start.sh

# private expose
EXPOSE 80

CMD ["/bin/bash", "/start.sh"]
