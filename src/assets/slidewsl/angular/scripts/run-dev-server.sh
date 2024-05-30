#!/usr/bin/env bash

echo "starting webpack dev server(s) for: $1"

declare -A app_configs=( )
while IFS='=' read -r key value; do
  if [[ -n $key ]]; then
    app_configs["$key"]="$value"
  fi
done < /usr/local/etc/angular/"${CONF_FILENAME:-dev-server.conf}"

if [ -z "$1" ]; then
  echo "no apps specified"
fi

for app in $1; do
  config="${app_configs[$app]}"
  if [ -z "$config" ]; then
    echo "error: unknown app '$app'"
  else
    echo "(if $app doesn't exist, you might see the error: Unknown arguments)"
    echo "running $config"
    eval "$config" 2>&1 | sed -u "s/^/$app | /" &
    echo "done"
  fi
done

wait
