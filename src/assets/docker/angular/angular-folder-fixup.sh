#!/usr/bin/env bash

echo -n "----------> checking ${ANGULAR_ROOT}... "
if [ -d "${ANGULAR_ROOT}" ]; then
  cd "${ANGULAR_ROOT}" || { echo unable to use angular folder; exit; }
  echo "good!"
else
  echo "fixing!"
  mkdir -p "${ANGULAR_ROOT}"
  cd "${ANGULAR_ROOT}" || { echo unable to use angular folder; exit; }

  project=$(basename "${ANGULAR_ROOT}")
  echo "----------> creating demo project: $project"
  ng new "$project" --directory . --create-application="false" --package-manager=yarn --skip-git=true --strict=false \
    && rm -f package-lock.json

  echo "----------> generating application: starter"
  yarn --cwd frontend run ng generate application "starter" --routing=true --style=scss

  echo "----------> done! back to it..."
fi

yarn install --frozen-lockfile

exec "$@"
