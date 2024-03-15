#!/usr/bin/env bash

mkdir -p /data/node1 /data/node2 /data/node3

if [ ! -f /data/nodes-01.conf ]; then touch /data/nodes-01.conf; fi
if [ ! -f /data/nodes-02.conf ]; then touch /data/nodes-02.conf; fi
if [ ! -f /data/nodes-03.conf ]; then touch /data/nodes-03.conf; fi

if [[ "$HOSTNAME" == "keydb-node1" ]]; then
  # throw this in the background so the CMD continues
  # we need keydb-server up before this runs
  {
    sleep 5
    # https://redis.io/docs/management/scaling/
    # https://github.com/redis/redis/issues/2186
    node1=$(getent hosts keydb-node1 | awk '{ print $1 }')
    node2=$(getent hosts keydb-node2 | awk '{ print $1 }')
    node3=$(getent hosts keydb-node3 | awk '{ print $1 }')
    redis-cli --cluster-yes --cluster create "$node1":6379 "$node2":6379 "$node3":6379 --cluster-replicas 0
  } &
fi

exec "$@"
