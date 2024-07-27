FROM ghcr.io/krkabol/php-fpm-noroot-socket:main@sha256-d106235ae43bb7430cd3d1cfdcf6d63912df06c1075a3b3deea488d61ad308f5
USER root
RUN apt-get update && apt-get dist-upgrade -y && \
    apt-get install -y --no-install-recommends \
        wget \
        imagemagick \
        libgraphicsmagick1-dev \
        libmagickwand-dev \
        libpq-dev \
        zbar-tools && \
        apt-get autoclean -y && \
        apt-get remove -y wget && \
        apt-get autoremove -y && \
        rm -rf /var/lib/apt/lists/* /var/lib/log/* /tmp/* /var/tmp/*

RUN  pecl install imagick-3.7.0
RUN  docker-php-ext-enable imagick && \
     docker-php-ext-install pdo

RUN  docker-php-ext-install pdo_pgsql
RUN  docker-php-ext-install pgsql
RUN  docker-php-ext-install opcache

#increase Imagick limits
COPY ./policy.xml /etc/ImageMagick-v6/policy.xml
USER www