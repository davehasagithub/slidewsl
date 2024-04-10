#!/usr/bin/env bash

exec chromium \
 --no-sandbox \
 --headless \
 --disable-gpu \
 --remote-debugging-port=9222 \
 "$@"
