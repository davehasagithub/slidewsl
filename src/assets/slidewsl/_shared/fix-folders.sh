#!/usr/bin/env sh

check_folder() {
  file="$1/is_writable"
  if ! touch "$file"; then
    exit 1
  fi
  rm "$file"
}

echo "checking folders"
mkdir -p "/host${SLIDEWSL_DB_ROOT_IN_WSL}" \
  "/host${SLIDEWSL_ANGULAR_ROOT_IN_WSL}" \
  "/host${SLIDEWSL_LARAVEL_ROOT_IN_WSL}" \
  "/host${SLIDEWSL_WEB_ROOT_IN_WSL}"

ls -ld "/host${SLIDEWSL_DB_ROOT_IN_WSL}" \
  "/host${SLIDEWSL_ANGULAR_ROOT_IN_WSL}" \
  "/host${SLIDEWSL_LARAVEL_ROOT_IN_WSL}" \
  "/host${SLIDEWSL_WEB_ROOT_IN_WSL}"

check_folder "/host${SLIDEWSL_DB_ROOT_IN_WSL}"
check_folder "/host${SLIDEWSL_ANGULAR_ROOT_IN_WSL}"
check_folder "/host${SLIDEWSL_LARAVEL_ROOT_IN_WSL}"
check_folder "/host${SLIDEWSL_WEB_ROOT_IN_WSL}"
