#!/usr/bin/env bash

chmod 644 /etc/my.cnf

exec "$@"
