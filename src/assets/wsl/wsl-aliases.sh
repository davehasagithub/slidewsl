dev() { (
  export ALIAS_USED=dev
  /docker/dev-admin.sh "$@"
); }

alias devhelp=". /etc/profile.d/motd.sh"
alias daveml="/usr/local/bin/daveml.sh"
