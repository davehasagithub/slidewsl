FROM php:7.4-fpm as base

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

RUN pecl install redis-5.2.1 \
	&& pecl install xdebug-3.0.4 \
	&& docker-php-ext-enable redis xdebug

RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

RUN wget -nv https://raw.githubusercontent.com/composer/getcomposer.org/c19391050a3d81f65e61049ebc30dbd4f5a99603/web/installer -O /tmp/composer_2.1.6.phar \
    && cat /tmp/composer_2.1.6.phar | php -- --version="2.1.6" --install-dir="/usr/local/bin" --filename="composer" \
    && mkdir -p /tools \
    && composer require --working-dir=/tools friendsofphp/php-cs-fixer:3.1.0 phpstan/phpstan:0.12.96 vimeo/psalm:4.9.3 --no-interaction

ENV PATH="$PATH:/usr/local/bin/php-scripts/"

USER php
ENTRYPOINT ["fixuid", "entrypoint.sh"]

FROM base as php-fpm

ENTRYPOINT ["fixuid", "prepare-vendor.sh", "docker-php-entrypoint"]
CMD ["php-fpm"]
