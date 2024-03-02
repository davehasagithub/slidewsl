#!/usr/bin/env bash

main() {
  sync "$@"

  OPT="${1:-}"
  shift

  if [[ "$OPT" == "status" ]]; then
    _call status
  elif [[ "$OPT" == "reset" ]]; then
    _call reset
    _call list
  elif [[ "$OPT" == "list" ]]; then
    _call list "$@"
  elif [[ "$OPT" == "recreate" ]]; then
    _call clean_dev_container
    _call run_container
  elif [[ "$OPT" == "" ]]; then
    _call run_container
  else
    usage
  fi
}

usage() {
  echo "| Usage: ${ALIAS_USED:-$0} [status|reset|list [stats]|recreate|help]"
  echo "| (If found, $script_path/sync.sh will run first.)"
  echo "| When no argument is provided:"
  echo "|   -Run or reattach to the $dev_container"
  echo "| Optional arguments:"
  echo "|   status: Report if the $dev_container is running"
  echo "|   reset: Stop and purge all containers and images"
  echo "|   list [stats]: List all containers, images, and optional stats"
  echo "|   recreate: Rebuild the $dev_container image and container"
  echo "|   help: Show this usage info"
  return 1
}

reset() {
  ids=$(docker ps -aq)
  if [[ "$ids" ]]; then
    # shellcheck disable=SC2086
    docker container stop $ids || true
  fi
  docker container prune -f || true
  docker image prune -af || true
}

clean_dev_container() {
  docker compose down --rmi all -t 2 "$dev_container" || true
}

run_container() {
  run_socat
  docker compose up -d "$dev_container"
  docker compose exec -it "$dev_container" bash
}

list() {
  HIGHLIGHT="\x1b[33;44m"
  NC='\033[0m'
  echo -e "\n${HIGHLIGHT} images ${NC}"
  docker image ls -a
  echo -e "\n${HIGHLIGHT} containers ${NC}"
  docker container ls -a
  if [[ "$1" == "stats" ]]; then
    echo -e "\n${HIGHLIGHT} stats ${NC}"
    echo -en "wait\r"
    docker stats --no-stream
  fi
  echo
}

run_socat() {
  if ! docker inspect -f '{{.State.Running}}' "socat" &>/dev/null; then
    echo "Launching socat"
    docker rm -f socat >/dev/null 2>&1 || true
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
    echo -n "Running sync.sh"
    initial_timestamp1=$(stat -c %Y "$0")
    initial_timestamp2=$(stat -c %Y "$script")
    $script
    current_timestamp1=$(stat -c %Y "$0")
    current_timestamp2=$(stat -c %Y "$script")
    if [[ "$current_timestamp1" -gt "$initial_timestamp1" || "$current_timestamp2" -gt "$initial_timestamp2" ]]; then
      echo ". Script updated. Relaunching..."
      exec "$0" "$*"
    else
      echo ". Script not updated. Continuing..."
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

export DOCKER_BUILDKIT=1
export COMPOSE_FILE="$script_path/compose.yaml"
export COMPOSE_FILE_PATH="$script_path"
export WSL_UID="$uid"
export WSL_GID="$gid"
export SRC_PATH_FRONTEND=~/src/ng1/frontend

main "$@"
