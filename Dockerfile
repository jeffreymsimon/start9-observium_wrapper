# Clone from SVN 
FROM alpine as clone

ARG SVN_USERNAME
ARG SVN_PASSWORD

WORKDIR /observium

RUN apk update && apk add subversion

RUN svn co --username $SVN_USERNAME --password $SVN_PASSWORD https://svn.observium.org/svn/observium/branches/stable .

# Start from fresh base image (so username/password aren't left in environment)
FROM ubuntu:16.04

RUN apt update && apt install -y \
    libapache2-mod-php7.0 \
    php7.0-cli \
    php7.0-mysql \
    php7.0-gd \
    php7.0-mcrypt \
    php7.0-json \
    php7.0-bcmath \
    php7.0-mbstring \
    php7.0-curl \
    php-apcu \
    php-pear \
    snmp \
    fping \
    rrdtool \
    whois \
    mysql-client \
    subversion \
    mtr-tiny \
    ipmitool \
    graphviz \
    imagemagick \
    apache2 \
    python-mysqldb

RUN a2dismod mpm_event \
    && a2enmod mpm_prefork \
    && a2enmod php7.0 \
    && a2enmod rewrite

# Tini
ENV TINI_VERSION v0.19.0
ENV TINI_ARCH amd64
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-${TINI_ARCH} /tini
RUN chmod +x /tini


WORKDIR /opt/observium

COPY --from=clone /observium ./

# Uncomment, or mount this file in container (better security, don't bake files w/ passwords in Docker images)
# ADD config.php config.php

ADD docker-entrypoint.sh /docker-entrypoint.sh

ADD observium-cron /etc/cron.d/observium
ADD sites-enabled /etc/apache2/sites-enabled

ENTRYPOINT ["/tini", "--", "/docker-entrypoint.sh"]
CMD [ "/bin/bash", "-c", "source /etc/apache2/envvars && /usr/sbin/apache2 -DFOREGROUND"]