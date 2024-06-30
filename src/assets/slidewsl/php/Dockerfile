ARG BUILD_IMAGE=undefined
ARG PHP_VERSION
FROM php:${PHP_VERSION}-fpm as base

USER root
ARG PHP_REDIS_VERSION

RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    apt-get update \
    && apt-get install -y \
      libjpeg62-turbo-dev \
      libpng-dev \
      libzip-dev \
      default-mysql-client \
      libxml2-dev \
      libicu-dev \
      wget \
      unzip \
    && docker-php-ext-configure gd --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd zip mysqli soap bcmath intl opcache pdo_mysql \
    && docker-php-ext-enable mysqli.so \
    # && docker-php-ext-enable opcache \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN pecl install redis-${PHP_REDIS_VERSION} \
	&& docker-php-ext-enable redis

RUN useradd php --create-home
RUN mkdir -p /app/laravel && chown -R php:php /app
WORKDIR /app/laravel

FROM base as development-base

ARG COMPOSER_HASH
ARG COMPOSER_VERSION
ARG XDEBUG_VERSION

RUN pecl install xdebug-${XDEBUG_VERSION} \
	&& docker-php-ext-enable xdebug

COPY --from=shared add-fixuid.sh /usr/local/bin
RUN add-fixuid.sh php php
RUN wget -nv https://raw.githubusercontent.com/composer/getcomposer.org/${COMPOSER_HASH}/web/installer -O /tmp/composer_${COMPOSER_VERSION}.phar \
    && cat /tmp/composer_${COMPOSER_VERSION}.phar | php -- --version="${COMPOSER_VERSION}" --install-dir="/usr/local/bin" --filename="composer"
ENV PATH="$PATH:/usr/local/bin/php-scripts/"

RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

FROM development-base as development

ARG PHP_CS_FIXER_VERSION
ARG PHP_STAN_VERSION
ARG PSALM_VERSION

RUN mkdir -p /tools \
    && composer require --working-dir=/tools friendsofphp/php-cs-fixer:${PHP_CS_FIXER_VERSION} phpstan/phpstan:${PHP_STAN_VERSION} vimeo/psalm:${PSALM_VERSION} --no-interaction

USER php
ENTRYPOINT ["fixuid", "entrypoint.sh"]

FROM development-base as php-fpm
ENTRYPOINT ["fixuid", "prepare-vendor.sh", "docker-php-entrypoint"]
CMD ["php-fpm"]

FROM ${BUILD_IMAGE} AS build-image

FROM base as deployable
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
ARG CONF=${CONF:-undefined}
RUN if [ "${CONF}" = "undefined" ]; then echo "CONF is not set"; exit 1; fi
COPY --from=build-image --chown=php:php /app/laravel /app/laravel/
COPY --chmod=0444 ${CONF}/* /etc/php/conf.d/
COPY --chmod=0444 etc/* /etc/php_extras/
USER php
