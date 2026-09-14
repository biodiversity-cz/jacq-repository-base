FROM ghcr.io/biodiversity-cz/php-fpm-noroot-socket:main@sha256:7e49b770330889e6a891185a07e5ccab8ab53406a05d990fbca384eed01731a9

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
     docker-php-ext-install exif

#increase Imagick limits
COPY ./policy.xml /etc/ImageMagick-6/policy.xml

COPY ./www.conf /usr/local/etc/php-fpm.d/zz-docker.conf

USER www
