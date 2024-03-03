#!/usr/bin/env bash

if [[ "$#" == 0 || "$#" -gt 3 ]]; then
  echo "usage: $0 <app> [<base-href> [<build-config>]]"
else
  app="$1"
  base_href="$2"
  config="$3"
  if [ "$#" -lt 3 ]; then
    config="development"
  fi
  if [ "$#" -lt 2 ]; then
    base_href="/"
  fi
  echo "building with: ng build $app --base-href=$base_href --configuration=$config"
  echo "(if $app doesn't exist, you might see the error: Unknown arguments)"
  ng build "$app" --base-href="$base_href" --configuration="$config"
  echo "done"
fi
