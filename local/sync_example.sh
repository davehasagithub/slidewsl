#!/usr/bin/env bash

root=/mnt/c/users/dave/Desktop/git/slidewsl
{
  echo "copying:"
  rsync -a --out-format='%n%L' $root/src/assets/slidewsl/ ~/slidewsl --delete

  echo "add customizations:"
  cp -a $root/local/dev-server.conf ~/slidewsl/angular/conf
  cp -a $root/local/docker-custom.env ~/slidewsl
  cp -a $root/local/docker-php.env ~/slidewsl
  cp -a $root/local/docker-phpmyadmin.env ~/slidewsl
  cp -a $root/local/php.extras.ini ~/slidewsl/php/conf
  cp -a $root/local/browscap.ini ~/slidewsl/php/scripts
  cp -a $root/local/sync.sh ~/slidewsl

  echo "dos2unix:"
  find ~/slidewsl -type f \( -not -name \*.enc \) -exec dos2unix -ic0 {} + | xargs -0 dos2unix

  echo "done"
}
