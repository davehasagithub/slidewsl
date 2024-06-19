#!/usr/bin/env sh

if ! docker network ls | grep -q builder-net; then
  echo "Creating builder-net network..."
  docker network create builder-net
fi

if ! docker buildx inspect my-builder >/dev/null 2>&1; then
  echo "Creating my-builder instance..."
  docker buildx create --name my-builder --driver-opt 'network=builder-net' --use
fi
