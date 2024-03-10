dcl() { (
  export ALIAS_USED=dcl
  /docker/devcontainer-launcher.sh "$@"
); }

dc-launcher() { (
  export ALIAS_USED=dc-launcher
  /docker/devcontainer-launcher.sh "$@"
); }

alias daveml="/usr/local/bin/daveml.sh"
