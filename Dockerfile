FROM prestashop/prestashop:latest

MAINTAINER Jean Baptsite Marchetti <marchetti.jb@gmail.com>

RUN rm -R /var/www/html/install-dev
COPY settings.inc.php /var/www/html/config/settings.inc.php


ENTRYPOINT ["/tmp/docker_run.sh"]
