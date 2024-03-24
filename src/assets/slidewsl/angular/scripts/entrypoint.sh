#!/usr/bin/env bash

case "$1" in
  "node_modules")
    prepare-node-modules.sh
    ;;
  "starter")
    create-starter-app.sh "${@:2}"
    prepare-node-modules.sh && build.sh "${@:2}"
    ;;
  "build")
    prepare-node-modules.sh && build.sh "${@:2}"
    ;;
  *)
    echo unknown action
    ;;
esac
