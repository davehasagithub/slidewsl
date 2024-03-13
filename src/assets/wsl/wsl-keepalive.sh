pid_file="/tmp/wsl-keepalive.pid"
pid=$(cat "$pid_file" 2>/dev/null || true)
ppid=1
if [ -n "$pid" ]; then
  ppid=$(ps -o ppid= -p "$pid" | awk '{print $1}')
fi
if test -z "$pid" || test "x$ppid" = "x1" ||  ! ps -p "$pid" >/dev/null; then
  dbus-launch true
  dbus_pid=$(pgrep -n dbus-daemon)
  echo "$dbus_pid" >"$pid_file"
fi
