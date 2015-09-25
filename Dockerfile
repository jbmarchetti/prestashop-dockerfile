FROM prestashop/prestashop:latest

MAINTAINER Jean Baptsite Marchetti <marchetti.jb@gmail.com>

RUN rm -R /var/www/html/install-dev

ENTRYPOINT ["/tmp/docker_run.sh"]
