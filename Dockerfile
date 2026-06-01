FROM ghcr.io/biodiversity-cz/php-fpm-noroot-socket:main@sha256:21d917553841403e6ffafc52d797f886873dbebc540652159f9b7199cfe6f1f7

MAINTAINER Petr Novotný <novotp@natur.cuni.cz>
LABEL org.opencontainers.image.source=https://github.com/biodiversity-cz/jacq-repository-base
LABEL org.opencontainers.image.description="base image for JACQ CZ repository"

USER root
RUN apt-get update && apt-get dist-upgrade -y && \
    apt-get install -y --no-install-recommends \
        wget \
        imagemagick \
        libgraphicsmagick1-dev \
        libmagickwand-dev \
        libopenjp2-tools \
        libpq-dev \
        zbar-tools \
        libzip-dev && \
        apt-get autoclean -y && \
        apt-get remove -y wget && \
        apt-get autoremove -y && \
        rm -rf /var/lib/apt/lists/* /var/lib/log/* /tmp/* /var/tmp/*

RUN  pecl install imagick
# if Imagick failed, see: https://github.com/Imagick/imagick/issues/643#issuecomment-1834361716


RUN  docker-php-ext-enable imagick && \
     docker-php-ext-install pdo && \
     docker-php-ext-install intl && \
     docker-php-ext-install pdo_pgsql && \
     docker-php-ext-install pgsql && \
     docker-php-ext-install zip && \
     docker-php-ext-install exif

#increase Imagick limits
COPY ./policy.xml /etc/ImageMagick-6/policy.xml

COPY ./www.conf /usr/local/etc/php-fpm.d/zz-docker.conf

USER www
