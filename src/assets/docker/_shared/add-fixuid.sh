#!/usr/bin/env bash

user=$1
group=$2
curl -SsL https://github.com/boxboat/fixuid/releases/download/v0.6.0/fixuid-0.6.0-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf -
chown root:root /usr/local/bin/fixuid
chmod 4755 /usr/local/bin/fixuid
mkdir -p /etc/fixuid
printf "user: %s\ngroup: %s\n" "$user" "$group" > /etc/fixuid/config.yml
