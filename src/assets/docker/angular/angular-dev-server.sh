#!/usr/bin/env bash

echo "starting webpack dev server(s) for: $1"
script_path=$(cd "$(dirname "$0")" && pwd)

declare -A app_configs=( )
source "$script_path"/angular-dev-server.conf.sh

for app in $1; do
  config="${app_configs[$app]}"
  if [ -z "$config" ]; then
    echo "error: unknown app '$app'"
  else
    echo "running $config"
    echo "(if $app doesn't exist, you might see the error: Unknown arguments)"
    eval "$config" 2>&1 | sed "s/^/$app | /" &
    echo "done"
  fi
done

wait
