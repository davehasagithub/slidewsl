#!/usr/bin/env bash

main() {
  OPT="${1:-}"

  if [[ "$OPT" == "sync" ]]; then
    _call sync "$@"
  elif [[ "$OPT" == "ij-clean" ]]; then
    _call ij-clean
  elif [[ "$OPT" == "reset" ]]; then
    shift
    _call reset "$@"
  elif [[ "$OPT" == "list" ]]; then
    shift
    _call list "$@"
  elif [[ "$OPT" == "stop" ]]; then
    _call stop
  else
    _call usage
  fi
}

usage() {
  cat <<EOF | sed "s/^    //"  | /usr/local/bin/daveml.sh -p "| "

    <WBB>   Welcome to SlideWSL!   <CLR>

    <CBX>To redisplay this info, type <CLR><KXW> dev <CLR> (or ~/slidewsl/dev-admin.sh)

    <GBX>Launch the environment <CLR><CXX>docker compose up -d
    <GBX>Tail the service logs  <CLR><CXX>docker compose logs -f
    <GBX>Run webpack dev server <CLR><CXX>APPS="<YBX><app> <CLR><YXX>[...]<CXX>" docker compose up --force-recreate angular-dev-server -d
    <GBX>Compile an angular app <CLR><CXX>docker compose run --rm angular build <YBX><app> <CLR><YXX>[<base-href> [<other-args...>]]
    <GBX>See what's running     <CLR><CXX>docker compose ps
    <GBX>Stop all services      <CLR><CXX>docker compose --profile "*" down -v

    <WXX>Tail a laravel log     <CXX>docker compose exec php-fpm tail -f storage/logs/laravel.log
    <WXX>Update node_modules    <CXX>docker compose run --rm angular node_modules
    <WXX>Update composer        <CXX>docker compose run --rm php composer
    <WXX>Make angular starter   <CXX>docker compose run --rm angular starter <YXX><app>
    <WXX>Make laravel starter   <CXX>docker compose run --rm php starter
    <WXX>Check keydb cluster    <CXX>docker compose exec -it keydb-node1 keydb-cli cluster info
    <WXX>Show angular version   <CXX>docker compose run --rm angular ng version
    <WXX>Run angular tests      <CXX>docker compose run --rm angular ng test <YXX><app><CXX> --watch=false
    <WXX>Show php version       <CXX>docker compose run --rm php php -v
    <WXX>Interactive terminal   <CXX>docker compose exec -it -u root <YXX><service><CXX> bash
    <WXX> ⤷ then, for example:  <CXX>apt update; apt install -y <YXX>iputils-ping iproute2 net-tools telnet vim less procps

    <WXX>Run sync.sh script     <CXX>${ALIAS_USED:-$0} sync
    <WXX>See Docker resources   <CXX>${ALIAS_USED:-$0} list <YXX>[stats]
    <WXX>Rm IJ containers+cache <CXX>${ALIAS_USED:-$0} ij-clean
    <WXX>Reset                  <CXX>${ALIAS_USED:-$0} reset <YXX>[cache]

EOF

  return 1
}

ij-clean() {
  # delete cache and kill containers
  read -r -p "It's recommended to shut down IntelliJ first. Ready? [y/N] " response
  response=${response,,}
  if [[ "$response" =~ ^(yes|y)$ ]]; then
    find /mnt/slidewsl/"$USER"/src -name ".angular" -type d -exec ls -ld {} \; -exec rm -rf {}/cache \;
    local ids
    ids=$(docker ps --no-trunc|grep js-language-service|awk '{ print $1 }' ORS=' ')
    echo "containers: $ids"
    if [[ "$ids" ]]; then
      # shellcheck disable=SC2086
      docker rm -f $ids || true
    fi
  fi
}

# hidden from usage
stop() {
  local ids
  ids=$(docker ps -q | awk '{print}' ORS=' ')
  echo "containers: $ids"
  if [[ "$ids" ]]; then
    # shellcheck disable=SC2086
    docker container stop $ids || true
  fi
}

reset() {
  read -r -p "Are you sure? [y/N] " response
  response=${response,,}
  if [[ "$response" =~ ^(yes|y)$ ]]; then
    stop
    docker container prune -f || true
    docker image prune -af || true
    docker volume prune -af || true
    docker network prune -f || true
    if [[ "$1" == "cache" ]]; then
      docker builder prune -af
    fi
    # docker system prune --all || true
    echo "done"
  fi
}

list() {
  local HIGHLIGHT NC
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
  echo -e "\n${HIGHLIGHT} buildx ${NC}"
  docker buildx ls
  echo -e "\n${HIGHLIGHT} contexts ${NC}"
  docker context ls
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
  local script initial_timestamp current_timestamp
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
  local func
  func=${1:-};
  shift;
  $func "$@"
}

main "$@"
