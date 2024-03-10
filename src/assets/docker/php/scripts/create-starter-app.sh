#!/usr/bin/env bash

cd "/laravel" || { echo unable to use laravel folder; exit 1; }

[ ! -f "/laravel/composer.json" ] || { echo "composer.json already exists"; exit 1; }

composer create-project laravel/laravel .
