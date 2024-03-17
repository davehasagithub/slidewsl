#!/usr/bin/env bash

main() {
  OPT="${1:-}"
  shift

  if [[ "$OPT" == "status" ]]; then
    _call status
  elif [[ "$OPT" == "reset" ]]; then
    _call reset "$@"
    _call list
  elif [[ "$OPT" == "list" ]]; then
    _call list "$@"
  elif [[ "$OPT" == "clean" ]]; then
    _call clean
  elif [[ "$OPT" == "help" ]]; then
    _call usage
  elif [[ "$OPT" == "" ]]; then
    _call run_container
  else
    echo "unknown option $OPT"
    _call usage
  fi
}

usage() {
  cat <<EOF | sed "s/^    //"  | daveml.sh -p "| "

    <BBX>Usage:
      <GBX>${ALIAS_USED:-$0} <CLR><GXX>[status|reset [cache]|list [stats]|clean|help]

    <BBX>When no argument is provided:
      Run or reattach to the $dev_container

    <BBX>Optional arguments:
      <GXX>status<CLR>        : Report if the $dev_container is running
      <GXX>reset [cache]<CLR> : Purge containers, images, volumes, networks, and (optional) build cache
      <GXX>list [stats]<CLR>  : List all containers, images, and (optional) stats
      <GXX>clean<CLR>         : Stop and remove the $dev_container container and image
      <GXX>help<CLR>          : Show this usage info

    <YBX>Aliases: <RXX>dcl<YBX> = <RXX>dc-launcher<YBX> = <RXX>/docker/devcontainer-launcher.sh

EOF

  return 1
}

reset() {
  if [[ "$1" == "cache" ]]; then
    docker builder prune -af
  fi
  ids=$(docker ps -aq)
  if [[ "$ids" ]]; then
    # shellcheck disable=SC2086
    docker container stop $ids || true
  fi
  docker container prune -f || true
  docker image prune -af || true
  docker volume prune -af || true
  docker network prune -f || true
  # docker system prune --all || true
  echo "done"
}

clean() {
  docker compose down --rmi all "$dev_container" 2>&1 || true
  docker container rm -f "$dev_container" >/dev/null 2>&1 || true
  docker image rm -f "$dev_container" >/dev/null 2>&1 || true
  echo "done"
}

run_container() {
  run_socat_docker_daemon
  docker compose up -d "$dev_container"
  docker compose exec -it "$dev_container" bash
  echo "|"
  echo "| Welcome back!"
  . /etc/profile.d/motd.sh
}

list() {
  HIGHLIGHT="\x1b[33;44m"
  NC='\033[0m'
  echo -e "\n${HIGHLIGHT} images ${NC}"
  docker image ls -a
  echo -e "\n${HIGHLIGHT} containers ${NC}"
  docker container ls -a
  echo -e "\n${HIGHLIGHT} networks ${NC}"
  docker network ls
  echo -e "\n${HIGHLIGHT} volumes ${NC}"
  docker volume ls
  echo -e "\n${HIGHLIGHT} resources ${NC}"
  docker system df
  if [[ "$1" == "stats" ]]; then
    echo -e "\n${HIGHLIGHT} stats ${NC}"
    echo -en "wait\r"
    docker stats --no-stream
  fi
  echo
}

run_socat_docker_daemon() {
  if ! docker inspect -f '{{.State.Running}}' "socat-docker-daemon" &>/dev/null; then
    LISTEN_HOST=127.0.0.1
    LISTEN_PORT=2376
    SOCKET=docker.sock
    echo "Launching socat-docker-daemon: ${LISTEN_HOST}:${LISTEN_PORT} => ${SOCKET}"
    docker rm -f socat-docker-daemon >/dev/null 2>&1 || true
    docker run --rm -d --name socat-docker-daemon \
      -p "${LISTEN_HOST}":"${LISTEN_PORT}":4000 \
      -v /var/run/docker.sock:/var/run/"${SOCKET}" \
      alpine/socat tcp-listen:4000,fork,reuseaddr unix-connect:/var/run/"${SOCKET}"
  fi
}

sync() {
  script="/docker/sync.sh"
  if [ -f "$script" ]; then
    echo "Running sync.sh"
    initial_timestamp1=$(stat -c %Y "$0")
    initial_timestamp2=$(stat -c %Y "$script")
    # don't run directly, the script itself could be updated while running
    cp "$script" /tmp/sync.sh
    chmod u+x /tmp/sync.sh
    /tmp/sync.sh
    rm /tmp/sync.sh
    current_timestamp1=$(stat -c %Y "$0")
    current_timestamp2=$(stat -c %Y "$script")
    if [[ "$current_timestamp1" -gt "$initial_timestamp1" || "$current_timestamp2" -gt "$initial_timestamp2" ]]; then
      echo "Script updated. Relaunching..."
      exec "$0" "$@"
    fi
  fi
}

status() {
  docker compose exec "$dev_container" sh -c 'ps -p 1' >/dev/null 2>&1
  result=$?
  echo "The $dev_container is $( (( result )) && echo 'not ')running"
  return $result
}

make_folder() {
  local folder=$1
  if [[ -n "$folder" && ! -d "$folder" ]]; then
    echo "creating angular root: $folder"
    if ! mkdir -p "$folder"; then
      exit 1
    fi
  fi
}

ensure_folders_exist() {
  (
    source "/docker/.env" 2>/dev/null || true
    source "/docker/.env.devcontainer" 2>/dev/null || true
    make_folder "$SLIDEWSL_ANGULAR_ROOT_IN_WSL"
    make_folder "$SLIDEWSL_LARAVEL_ROOT_IN_WSL"
    make_folder "$SLIDEWSL_WEB_ROOT_IN_WSL"
    make_folder "$SLIDEWSL_DB_ROOT_IN_WSL"
  )
  subshell_exit_code=$?
  if [ "$subshell_exit_code" -ne 0 ]; then
    exit $subshell_exit_code;
  fi
}

_call() {
  func=${1:-}; shift; $func "$@"
}

# ---------------------------------------------------------------------------

dev_container=devcontainer

sync "$@"
ensure_folders_exist
main "$@"
