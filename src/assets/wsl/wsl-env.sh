export DOCKER_BUILDKIT=1
export COMPOSE_FILE="$HOME/slidewsl/compose.local.yaml"
export COMPOSE_ENV_FILES="$HOME/slidewsl/_env/local.env"

WSL_UID=$(id -u)
WSL_GID=$(id -g)
export WSL_UID
export WSL_GID

WSL2_GATEWAY=$(ip route show | grep -i default | awk '{ print $3}')
export WSL2_GATEWAY
