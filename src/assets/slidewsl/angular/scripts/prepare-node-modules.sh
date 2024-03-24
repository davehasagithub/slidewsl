#!/usr/bin/env bash

# check angular.json exists and build node_modules

if [ ! -f "/angular/angular.json" ]; then
  echo "no angular.json found in /angular"
  exit 1;
fi

cd "/angular" || { echo unable to use angular folder; exit 1; }

if yarn install --frozen-lockfile; then
  exec "$@"
fi
