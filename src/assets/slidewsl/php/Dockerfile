ARG PHP_VERSION
FROM php:${PHP_VERSION}-fpm as base

ARG PHP_REDIS_VERSION
ARG XDEBUG_VERSION
ARG COMPOSER_HASH
ARG COMPOSER_VERSION
ARG PHP_CS_FIXER_VERSION
ARG PHP_STAN_VERSION
ARG PSALM_VERSION

#RUN useradd --system --no-create-home --home /nonexistent --shell /bin/false php
RUN useradd php --create-home

COPY --from=shared add-fixuid.sh /usr/local/bin
RUN add-fixuid.sh php php

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
	&& pecl install xdebug-${XDEBUG_VERSION} \
	&& docker-php-ext-enable redis xdebug

RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

RUN wget -nv https://raw.githubusercontent.com/composer/getcomposer.org/${COMPOSER_HASH}/web/installer -O /tmp/composer_${COMPOSER_VERSION}.phar \
    && cat /tmp/composer_${COMPOSER_VERSION}.phar | php -- --version="${COMPOSER_VERSION}" --install-dir="/usr/local/bin" --filename="composer" \
    && mkdir -p /tools \
    && composer require --working-dir=/tools friendsofphp/php-cs-fixer:${PHP_CS_FIXER_VERSION} phpstan/phpstan:${PHP_STAN_VERSION} vimeo/psalm:${PSALM_VERSION} --no-interaction

ENV PATH="$PATH:/usr/local/bin/php-scripts/"

WORKDIR /laravel

USER php
ENTRYPOINT ["fixuid", "entrypoint.sh"]

FROM base as php-fpm

ENTRYPOINT ["fixuid", "prepare-vendor.sh", "docker-php-entrypoint"]
CMD ["php-fpm"]
