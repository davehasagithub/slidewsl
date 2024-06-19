#!/usr/bin/env bash

cd "/app/laravel" || { echo unable to use laravel folder; exit 1; }

[ ! -f "/app/laravel/composer.json" ] || { echo "composer.json already exists"; exit 1; }

composer create-project laravel/laravel .
