FROM ghcr.io/krkabol/php-fpm-noroot-socket:main@sha256:661daad0dd3e579dae5ecc7acd8848e51868d5128e37a8a15bc15544adc656e8
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

# https://gist.github.com/Wirone/d5c794b4fef0203146a27687e80588a6
#RUN  pecl install imagick-3.7.0
# Imagick is installed from the archive because regular installation fails
# See: https://github.com/Imagick/imagick/issues/643#issuecomment-1834361716
ARG IMAGICK_VERSION=3.7.0
RUN curl -L -o /tmp/imagick.tar.gz https://github.com/Imagick/imagick/archive/tags/${IMAGICK_VERSION}.tar.gz \
    && tar --strip-components=1 -xf /tmp/imagick.tar.gz \
    && phpize \
    && ./configure \
    && make \
    && make install \
    && echo "extension=imagick.so" > /usr/local/etc/php/conf.d/ext-imagick.ini \
    && rm -rf /tmp/*
    # <<< End of Imagick installation

RUN  docker-php-ext-enable imagick && \
     docker-php-ext-install pdo && \
     docker-php-ext-install intl && \
     docker-php-ext-install pdo_pgsql && \
     docker-php-ext-install pgsql && \
     docker-php-ext-install opcache && \
     docker-php-ext-install exif

#increase Imagick limits
COPY ./policy.xml /etc/ImageMagick-6/policy.xml
USER www
