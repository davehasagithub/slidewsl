#!/usr/bin/env bash

main() {
  OPT="${1:-}"
  shift

  if [[ "$OPT" == "status" ]]; then
    _call status
  elif [[ "$OPT" == "clean" ]]; then
    _call clean
  elif [[ "$OPT" == "recreate" ]]; then
    _call run_container recreate
  elif [[ "$OPT" == "" ]]; then
    _call run_container
  else
    usage
  fi
}

usage() {
  echo "| Usage: ${ALIAS_USED:-$0} [status|clean|recreate|help]"
  echo "| When no argument is provided:"
  echo "|   -Run or reattach to the $dev_container"
  echo "|    (If found, $script_path/sync.sh will run first.)"
  echo "| Optional arguments:"
  echo "|   status: Check if the $dev_container is running"
  echo "|   clean: Purge related containers and images"
  echo "|   recreate: Force rebuild of the $dev_container"
  echo "|   help: Show this usage info"
  return 1
}

run_container() {
  status || true
  local recreate=
  sync
  run_socat
  [ "$1" == 'recreate' ] && recreate='--force-recreate'
  docker compose --profile "$dev_container" up -d $recreate
  docker compose exec -it "$dev_container" bash
}

clean() {
  docker rm -f socat 2>/dev/null || true
  docker rmi -f alpine/socat 2>/dev/null || true
  docker compose down --rmi all -t 0 "$dev_container"
}

run_socat() {
  if ! docker inspect -f '{{.State.Running}}' "socat" &>/dev/null; then
    echo "Launching socat"
    docker rm -f socat 2>/dev/null || true
    docker run --rm -d --name socat \
      -p 127.0.0.1:2376:4000 \
      -v /var/run/docker.sock:/var/run/docker.sock \
      alpine/socat \
      tcp-listen:4000,fork,reuseaddr unix-connect:/var/run/docker.sock
  else
    echo "socat is already running"
  fi
}

sync() {
  script="$script_path/sync.sh"
  if [ -f "$script" ]; then
    echo "Running sync.sh"
    initial_timestamp=$(stat -c %Y "$0")
    $script
    current_timestamp=$(stat -c %Y "$0")
    if [ "$current_timestamp" -gt "$initial_timestamp" ]; then
      echo "Script has been updated. Relaunching $0"
      exec "$0"
    else
      echo "Script was not updated. Continuing"
    fi
  fi
}

status() {
  docker compose exec "$dev_container" sh -c 'ps -p 1' >/dev/null 2>&1
  result=$?
  echo "The $dev_container is $( (( result )) && echo 'not ')running"
  return $result
}

_call() {
  func=${1:-}; shift; $func "$@"
}

script_path=$(cd "$(dirname "$0")" && pwd)
dev_container=devcontainer
uid=$(id -u)
gid=$(id -g)

export COMPOSE_FILE="$script_path/compose.yaml"
export COMPOSE_FILE_PATH="$script_path"
export WSL_UID="$uid"
export WSL_GID="$gid"

main "$@"
