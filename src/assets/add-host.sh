#!/usr/bin/env bash

if [[ -n "$1" && -n "$2" ]]; then
  echo "$2" "$1" | tee -a /etc/hosts.wsl /etc/hosts
else
  echo "Usage: $0 <host> <ip>"
fi
