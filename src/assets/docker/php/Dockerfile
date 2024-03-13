FROM php:7.4-fpm as base

#RUN useradd --system --no-create-home --home /nonexistent --shell /bin/false php
RUN useradd php --create-home

COPY --from=shared add-fixuid.sh /usr/local/bin
RUN add-fixuid.sh php php

RUN --mount=type=cache,target=/var/cache/apt \
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

COPY php.ini "$PHP_INI_DIR"
COPY php.*.ini "$PHP_INI_DIR"
COPY extras/* "$PHP_INI_DIR/extras/"
RUN cat $PHP_INI_DIR/php.*.ini >>$PHP_INI_DIR/php.ini || true

RUN wget -nv https://raw.githubusercontent.com/composer/getcomposer.org/c19391050a3d81f65e61049ebc30dbd4f5a99603/web/installer -O /tmp/composer_2.1.6.phar \
    && cat /tmp/composer_2.1.6.phar | php -- --version="2.1.6" --install-dir="/usr/local/bin" --filename="composer"

COPY scripts/prepare-vendor.sh /usr/local/bin

# RUN curl -sL -o /usr/local/bin/dbgpProxy https://xdebug.org/files/binaries/dbgpProxy
# RUN chmod 755 /usr/local/bin/dbgpProxy

USER php
ENTRYPOINT ["fixuid", "prepare-vendor.sh"]

FROM base as starter

COPY scripts/create-starter-app.sh /usr/local/bin
ENTRYPOINT ["fixuid", "create-starter-app.sh"]

FROM base as fpm

ENTRYPOINT ["fixuid", "prepare-vendor.sh", "docker-php-entrypoint"]
CMD ["php-fpm"]
