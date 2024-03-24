#!/usr/bin/env bash

mkdir -p /data/node1 /data/node2 /data/node3

if [ ! -f /data/nodes-01.conf ]; then touch /data/nodes-01.conf; fi
if [ ! -f /data/nodes-02.conf ]; then touch /data/nodes-02.conf; fi
if [ ! -f /data/nodes-03.conf ]; then touch /data/nodes-03.conf; fi

if [[ "$HOSTNAME" == "keydb-node1" ]]; then
  # throw this in the background so the CMD continues
  # we need keydb-server up before this runs
  {
    max_attempts=100
    retry_interval=5

    echo "Cluster init"
    for (( attempt=1; attempt<=max_attempts; attempt++ )); do
      # https://redis.io/docs/management/scaling/
      # https://github.com/redis/redis/issues/2186
      node1=$(getent hosts keydb-node1 | awk '{ print $1 }')
      node2=$(getent hosts keydb-node2 | awk '{ print $1 }')
      node3=$(getent hosts keydb-node3 | awk '{ print $1 }')
      if [[ -n "$node1" && -n "$node2" && -n "$node3" ]]; then
        echo "Attempt $attempt to create cluster..."
        if redis-cli --cluster-yes --cluster create "$node1":6379 "$node2":6379 "$node3":6379 --cluster-replicas 0; then
          echo "Cluster creation successful!"
          break
        fi

        if [ $((attempt % 3)) -eq 0 ]; then
          echo "Flush and reset."
          echo -e "flushall\ncluster reset" | redis-cli -h "$node1"
          echo -e "flushall\ncluster reset" | redis-cli -h "$node2"
          echo -e "flushall\ncluster reset" | redis-cli -h "$node3"
        fi
      else
        echo "Unable to resolve all nodes - node1: $node1, node2: $node2, node3: $node3"
      fi
      echo "Retrying in $retry_interval seconds..."
      sleep $retry_interval
    done
  } &
fi

exec "$@"
