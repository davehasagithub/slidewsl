#!/usr/bin/env bash

case "$1" in
  "composer")
    prepare-vendor.sh
    ;;
  "starter")
    create-starter-app.sh "${@:2}"
    ;;
  *)
    exec "$@"
    ;;
esac
