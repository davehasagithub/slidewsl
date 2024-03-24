export DOCKER_BUILDKIT=1
export COMPOSE_FILE="$HOME/slidewsl/compose.yaml"

WSL_UID=$(id -u)
WSL_GID=$(id -g)
export WSL_UID
export WSL_GID

WSL2_GATEWAY=$(ip route show | grep -i default | awk '{ print $3}')
export WSL2_GATEWAY
