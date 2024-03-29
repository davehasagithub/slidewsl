#!/usr/bin/env bash

[ -n "$1" ] || { echo "app name not provided"; exit 1; }

cd "/angular" || { echo unable to use angular folder; exit 1; }

if [ ! -f "/angular/angular.json" ]; then
  project="demo"
  echo "creating new project"
  ng new "$project" --directory . --create-application="false" --package-manager=yarn --skip-git=true --strict=false \
    && rm -f package-lock.json
fi

app="${1:-starter}"
echo "generating application: $app"
yarn run ng generate application "$app" --routing=true --style=scss

cat <<EOF | sed "s/^  //" >"projects/$app/src/app/app.component.html"
  <p style="margin: 1em">
    Future home of the <b>$app</b> app!
  </p>
EOF
