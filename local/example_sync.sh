#!/usr/bin/env bash

root=/mnt/c/users/dave/Desktop/git/slidewsl
{
  echo "copying:"
  rsync -a --out-format='%n%L' $root/src/assets/slidewsl/ ~/slidewsl --delete

  echo "add customizations:"
  cp -a $root/local/dev-server.conf ~/slidewsl/node/conf
  cp -a $root/local/php.extras.ini ~/slidewsl/php/conf
  cp -a $root/local/lite_php_browscap.ini ~/slidewsl/php/etc
  cp -a $root/local/sync.sh ~/slidewsl
  cp -a $root/local/cert.* ~/slidewsl/nginx/certs

  go run ~/slidewsl/_templates/cmd/render.go --env-file ~/slidewsl/_env/local.env --environment local --workspace-path ~/slidewsl; \
  go run ~/slidewsl/_templates/cmd/render.go --env-file ~/slidewsl/_env/build.env --environment build --workspace-path ~/slidewsl; \
  go run ~/slidewsl/_templates/cmd/render.go --env-file ~/slidewsl/_env/staging.env --environment staging --workspace-path ~/slidewsl; \
  cp ~/slidewsl/compose*.yaml $root/src/assets/slidewsl/

  echo "dos2unix:"
  find ~/slidewsl -type f \( -not -name \*.enc \) -exec dos2unix -ic0 {} + | xargs -0 dos2unix

  echo "done"
}
