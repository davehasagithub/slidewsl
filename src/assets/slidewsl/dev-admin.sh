#!/usr/bin/env bash

main() {
  OPT="${1:-}"

  if [[ "$OPT" == "sync" ]]; then
    _call sync "$@"
  elif [[ "$OPT" == "reset" ]]; then
    shift
    _call reset "$@"
    _call list
  elif [[ "$OPT" == "list" ]]; then
    shift
    _call list "$@"
  elif [[ "$OPT" == "clean" ]]; then
    _call clean
  else
    _call usage
  fi
}

usage() {
  cat <<EOF | sed "s/^    //"  | /usr/local/bin/daveml.sh -p "| "

    <WBB>   Welcome to the SlideWSL development environment!   <CLR>

    <CBX>To redisplay this info, type <CLR><KXW> dev <CLR> (or ~/slidewsl/dev-admin.sh)

    <GBX>Launch the environment <CLR><CXX>docker compose up -d
    <GBX>Tail the service logs  <CLR><CXX>docker compose logs -f
    <GBX>Run webpack dev server <CLR><CXX>APPS="<YBX><app> <CLR><YXX>[...]<CXX>" docker compose up --force-recreate angular_dev_server -d
    <GBX>Compile an angular app <CLR><CXX>docker compose run --rm angular build <YBX><app> <CLR><YXX>[<base-href> [<other-args...>]]
    <GBX>See what's running     <CLR><CXX>docker compose ps
    <GBX>Stop all services      <CLR><CXX>docker compose --profile "*" down

    <WXX>Tail a laravel log     <CXX>docker compose exec php-fpm tail -f /laravel/storage/logs/laravel_line-<YXX>YYYY<CXX>-<YXX>MM<CXX>-<YXX>DD<CXX>.log
    <WXX>Update node_modules    <CXX>docker compose run --rm angular node_modules
    <WXX>Update composer        <CXX>docker compose run --rm php composer
    <WXX>Make angular starter   <CXX>docker compose run --rm angular starter <YXX><app>
    <WXX>Make laravel starter   <CXX>docker compose run --rm php starter
    <WXX>Check keydb cluster    <CXX>docker compose exec -it keydb-node1 keydb-cli cluster info
    <WXX>Interactive terminal   <CXX>docker compose exec -it -u root <YXX><service><CXX> bash
    <WXX>                        ⤷ then, for example: <CXX>apt update; apt install -y <YXX>iputils-ping telnet vim less

    <WXX>Run sync.sh script     <CXX>${ALIAS_USED:-$0} sync
    <WXX>See Docker resources   <CXX>${ALIAS_USED:-$0} list <YXX>[stats]
    <WXX>Reset                  <CXX>${ALIAS_USED:-$0} reset <YXX>[cache]

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

sync() {
  script="$HOME/slidewsl/sync.sh"
  if [ -f "$script" ]; then
    echo "Running sync.sh"
    initial_timestamp=$(stat -c %Y "$script")
    # don't run directly, the script itself could be updated while running
    cp "$script" /tmp/sync.sh
    chmod u+x /tmp/sync.sh
    /tmp/sync.sh
    rm /tmp/sync.sh
    current_timestamp=$(stat -c %Y "$script")
    if [[ "$current_timestamp" -gt "$initial_timestamp" ]]; then
      echo "Script updated. Relaunching..."
      exec "$0" "$@"
    fi
  else
    echo "script not found: $script"
  fi
}

_call() {
  func=${1:-}; shift; $func "$@"
}

main "$@"
