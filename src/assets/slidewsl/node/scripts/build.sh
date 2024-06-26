#!/usr/bin/env bash

if [[ "$#" == 0 ]]; then
  echo "usage: $0 <app> [<base-href> [<other-build-args>]]"
else
  cd "/app/angular" || { echo unable to use angular folder; exit 1; }

  app="$1"
  base_href="${2:-/}"
  other_build_args=
  if [ "$#" -gt 2 ]; then
    shift 2
    other_build_args=$*
  fi
  echo "(if $app doesn't exist, you might see the error: Unknown arguments)"
  echo "building with: ng build $app --base-href=$base_href $other_build_args"
  # shellcheck disable=SC2086
  ng build "$app" --base-href="$base_href" $other_build_args
  echo "done"
fi
