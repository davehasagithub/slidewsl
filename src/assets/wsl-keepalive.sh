pid_file="/tmp/wsl-keepalive.pid"
pid=$(cat "$pid_file" 2>/dev/null || true)
if test -z "$pid" || ! ps -p "$pid" >/dev/null; then
  dbus-launch true
  dbus_pid=$(pgrep -n dbus-daemon)
  echo "$dbus_pid" >"$pid_file"
fi
