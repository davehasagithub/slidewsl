#!/usr/bin/env bash

if [ ! -f "/laravel/composer.json" ]; then
  echo "no composer.json found in /laravel"
  exit 1;
fi

cd "/laravel" || { echo unable to use composer folder; exit 1; }

if composer install; then
  exec "$@"
fi
