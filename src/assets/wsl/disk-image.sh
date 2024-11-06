#!/usr/bin/env bash

# https://wangziqi2013.github.io/article/2022/03/09/qemu-cheat-sheet.html
# https://www.baeldung.com/linux/mount-qcow2-image

declare -a pids

get_pids() {
  # this approach finds pids missed by lsof and fuser
  local current_pid pids_with_parents mounts
  current_pid=$$
  pids_with_parents=$(ps -e -o pid= -o ppid=)
  while read -r pid ppid; do
    if ! { [[ $pid -eq $current_pid || $ppid -eq $current_pid ]] || grep -q "Z" "/proc/$pid/status"; }; then
      mounts=$(awk '{print $1}' "/proc/$pid/mounts")
      if echo "$mounts" | grep -q "/dev/nbd0"; then
        pids+=("$pid")
      fi
    fi
  done <<< "$pids_with_parents" 2>/dev/null
}

# shellcheck disable=SC2086
stop_containers() {
  local ids
  ids=$(docker ps -q)
  echo "- containers: " $ids
  if [[ "$ids" ]]; then
    docker container stop $ids >/dev/null 2>&1 || true
  fi
}

kill_procs() {
  local pids
  stop_containers
  pids=()
  get_pids
  echo "- pids list: " "${pids[@]}"
  if [[ ${#pids[@]} -gt 0 ]]; then
    for pid in "${pids[@]}"; do
      if [[ $1 == "force" ]]; then
        echo "- kill -9 $pid"
        kill -9 "$pid" 2>/dev/null
      else
        echo "- kill $pid"
        kill "$pid" 2>/dev/null
      fi
    done
    return 0
  fi
  return 1
}

stop() {
  # sudo bash -c "umount /dev/nbd0; qemu-nbd --disconnect /dev/nbd0"
  if ! umount /dev/nbd0; then
    echo "- umount failed"
  else
    echo "- umount ok"
  fi

  if ! qemu-nbd --disconnect /dev/nbd0; then
    echo "- disconnect failed"
  else
    echo "- disconnect ok"
  fi

  echo "- stopping processes that are using nbd0"
  if kill_procs; then
    echo "- checking again in 10s"
    sleep 1
    kill_procs force
  fi
}

start() {
  if [[ ! -f "$IMG_LOCATION" && ! -d "$IMG_LOCATION" ]]; then
    qemu-img create -f qcow2 "$IMG_LOCATION" 20G
    echo "- create image: done"
  else
    echo "- create image: already exists"
  fi

  if grep -q "^/dev/nbd0 " /proc/mounts || [[ -e /sys/block/nbd0/size && "$(cat /sys/block/nbd0/size 2>/dev/null)" != "0" ]]; then
    echo "- connect nbd: already connected"
  else
    qemu-nbd --connect=/dev/nbd0 "$IMG_LOCATION"
    echo "- connect nbd: done"
  fi

  fs_type=$(blkid -s TYPE -o value /dev/nbd0)
  if [[ "$fs_type" == "" ]]; then
    mkfs.ext4 -q /dev/nbd0
    echo "- create file system: done"
  else
    echo "- create file system: already exists as ${fs_type}"
  fi

  mkdir -p "$MOUNT_LOCATION"
  if ! mount | grep -q "/dev/nbd0 on $MOUNT_LOCATION"; then
    mount /dev/nbd0 "$MOUNT_LOCATION"
    echo "- mounting: done"
  else
    echo "- mounting: already mounted"
  fi

  chmod 1777 "$MOUNT_LOCATION"
  echo "- update permissions: done"
}

failed() {
  echo "Error: Command \"$BASH_COMMAND\" failed with exit code $?"
  #exit 1
}

trap 'failed' ERR

[ -f "/etc/disk-image.conf" ] && source /etc/disk-image.conf

export MOUNT_LOCATION=/mnt/slidewsl/

echo "$1 request for image [$IMG_LOCATION]"
[ -n "${IMG_LOCATION}" ] || { echo "- image ignored"; exit 1; }

modprobe nbd max_part=8

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  *)
    echo "Usage: $0 {start|stop}"
    exit 1
    ;;
esac

echo "- complete"
