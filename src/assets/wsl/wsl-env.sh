export DOCKER_BUILDKIT=1
export COMPOSE_FILE="/docker/compose.yaml"

WSL_UID=$(id -u)
WSL_GID=$(id -g)
export WSL_UID
export WSL_GID
