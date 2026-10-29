FROM ghcr.io/biodiversity-cz/php-fpm-noroot-socket:main@sha256:374990e47a7e85e6817528ace6360ec24102d62c0d6dcab0ae9f5bd899debb03

MAINTAINER Petr Novotný <novotp@natur.cuni.cz>
LABEL org.opencontainers.image.source=https://github.com/biodiversity-cz/jacq-repository-base
LABEL org.opencontainers.image.description="base image for JACQ CZ repository"

ARG SAXON_VERSION=12.10
ARG SAXON_RELEASE=SaxonHE12-10
USER root
RUN apt-get update && apt-get dist-upgrade -y && \
    apt-get install -y --no-install-recommends \
        default-jre-headless \
        unzip \
        wget \
        imagemagick \
        libgraphicsmagick1-dev \
        libmagickwand-dev \
        libopenjp2-tools \
        libpq-dev \
        zbar-tools \
        libzip-dev && \
        apt-get autoclean -y && \
#        apt-get remove -y wget && \
        apt-get autoremove -y && \
        rm -rf /var/lib/apt/lists/* /var/lib/log/* /tmp/* /var/tmp/*


RUN     mkdir -p /opt/saxon && \
        wget -q \
            "https://github.com/Saxonica/Saxon-HE/releases/download/${SAXON_RELEASE}/${SAXON_RELEASE}J.zip" \
            -O /tmp/saxon.zip && \
        unzip -q /tmp/saxon.zip -d /opt/saxon && \
        rm /tmp/saxon.zip && \
        test -n "$(find /opt/saxon -name "saxon-he-${SAXON_VERSION}.jar" -print -quit)" && \
        java -cp '/opt/saxon/*' net.sf.saxon.Transform -? >/dev/null 2>&1


RUN  pecl install imagick
# if Imagick failed, see: https://github.com/Imagick/imagick/issues/643#issuecomment-1834361716

RUN  docker-php-ext-enable imagick && \
     docker-php-ext-install exif

#increase Imagick limits
COPY ./policy.xml /etc/ImageMagick-6/policy.xml

COPY ./www.conf /usr/local/etc/php-fpm.d/zz-docker.conf

USER www
