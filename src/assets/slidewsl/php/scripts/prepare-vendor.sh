#!/usr/bin/env bash

if [ ! -f "/app/laravel/composer.json" ]; then
  echo "no composer.json found in /app/laravel"
  exit 1;
fi

cd "/app/laravel" || { echo unable to use composer folder; exit 1; }

if composer install --no-interaction --optimize-autoloader; then
  exec "$@"
fi
