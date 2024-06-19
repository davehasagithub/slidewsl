#!/usr/bin/env bash

main() {
  _call init "$@"
  _call base_installs
  _call keep_distro_running
  _call install_docker
  _call install_xfce_and_xrdp
  _call install_sshd
  _call install_browsers
  _call install_jetbrains_toolbox
  _call set_up_env
  _call set_up_nbd
  _call set_up_skel
  _call set_up_user
}

init() {
  if [ "$USER" != "root" ]; then
    echo "Error: user isn't root"
    exit 1
  fi

  if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
    echo "Usage: $0 <username> <password> <user-profile-folder>"
    exit 1
  fi

  # echo 'hosts: files dns' > /etc/nsswitch.conf
  # ulimit -n 1024

  export username="$1"
  export password="$2"
  user_profile_folder=$(wslpath "$3")
  export user_profile_folder
  asset_folder="$(pwd)"
  export asset_folder
  cd ~ || exit
}

base_installs() {
  dnf install -y dnf-utils zip unzip git bash-completion dbus-x11 telnet which hostname rsync lsof qemu-img jq golang
  dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
  /usr/bin/crb enable
}

# Unusual because dbus-launch needs to be a child of the wsl init process. so, we can't use systemd,
# a @reboot cron job, wsl.conf [boot] (windows 11 only), or setuid (doesn't apply to shell scripts)
keep_distro_running() {
  cp "$asset_folder/wsl-keepalive-profiled.sh" /etc/profile.d/wsl-keepalive.sh
  cp "$asset_folder/wsl-keepalive.sh" /usr/local/bin
  chmod 644 /etc/profile.d/wsl-keepalive.sh
  chmod 755 /usr/local/bin/wsl-keepalive.sh
  echo "ALL ALL=(ALL) NOPASSWD: /usr/local/bin/wsl-keepalive.sh" | sudo tee -a /etc/sudoers.d/wsl-keepalive
  chmod 440 /etc/sudoers.d/wsl-keepalive
  . /etc/profile.d/wsl-keepalive.sh
}

# https://docs.docker.com/config/daemon/troubleshoot/#use-the-hosts-key-in-daemonjson-with-systemd
# https://unix.stackexchange.com/a/468067
install_docker() {
  dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
  dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  mkdir -p /etc/docker
  mkdir -p /etc/systemd/system/docker.service.d
  cp "$asset_folder/docker-daemon.json" /etc/docker/daemon.json
  cp "$asset_folder/docker-override.conf" /etc/systemd/system/docker.service.d/override.conf
  chmod 644 /etc/docker/daemon.json
  chmod 644 /etc/systemd/system/docker.service.d/override.conf
  systemctl enable --now docker.service
  cp "$asset_folder/local-registry-list.sh" /usr/local/bin/local-registry-list.sh
  chmod 755 /usr/local/bin/local-registry-list.sh
}

# https://github.com/neutrinolabs/xrdp/issues/2491
install_xfce_and_xrdp() {
  dnf group install -y --setopt=group_package_types="mandatory" xfce
  dnf install -y xrdp xfce4-terminal xfce4-appfinder
  cp "$asset_folder/systemd-user-context.sh" /usr/libexec/xrdp/systemd-user-context.sh
  chmod +x /usr/libexec/xrdp/systemd-user-context.sh
  wm_fixup="if [ -x /usr/bin/systemctl -a \"\$XDG_RUNTIME_DIR\" = \"/run/user/\"\`id -u\` ]; then eval \"\`\${0%/*}/systemd-user-context.sh init -p \$\$\`\"; fi"
  sed -i "/^wm_start$/i $wm_fixup" /usr/libexec/xrdp/startwm.sh
  sed -ri "s#\. /etc/X11/xinit/Xsession#startxfce4#" /usr/libexec/xrdp/startwm.sh
  sed -ri "s/^port=3389/port=3390/" /etc/xrdp/xrdp.ini
  systemctl enable --now xrdp
}

install_sshd() {
  sed -ri "s/^#?Port .*/Port 2223/" /etc/ssh/sshd_config
}

install_browsers() {
  dnf install -y firefox chromium
}

install_jetbrains_toolbox() {
  dnf install -y fuse fuse-libs
  jb_toolbox=jetbrains-toolbox-2.2.1.19765.tar.gz
  curl -sL https://download.jetbrains.com/toolbox/$jb_toolbox | tar -C /opt -xzf -
}

set_up_env() {
  cp "$asset_folder/wsl-env.sh" /etc/profile.d
  cp "$asset_folder/wsl-ps1.sh" /etc/profile.d
  cp "$asset_folder/wsl-aliases.sh" /etc/profile.d
  cp "$asset_folder/motd.sh" /etc/profile.d
  chmod 644 /etc/profile.d/wsl-env.sh
  chmod 644 /etc/profile.d/wsl-ps1.sh
  chmod 644 /etc/profile.d/wsl-aliases.sh
  chmod 644 /etc/profile.d/motd.sh

  curl -sL -o /usr/local/bin/daveml.sh https://raw.githubusercontent.com/davehasagithub/daveml/main/daveml.sh
  chmod 755 /usr/local/bin/daveml.sh
}

set_up_nbd() {
  echo "IMG_LOCATION=$user_profile_folder/slidewsl.img" >/etc/disk-image.conf
  cp "$asset_folder/disk-image.sh" /usr/local/bin/slidewsl-img.sh
  chmod 755 /usr/local/bin/slidewsl-img.sh
  cp "$asset_folder/disk-image.service" /etc/systemd/system
  systemctl enable --now disk-image.service
}

set_up_skel() {
  # prevent conflict with bash control-p for previous command
  mkdir -p /etc/skel/.docker
  cp "$asset_folder"/docker-config.json /etc/skel/.docker/config.json

  echo "cd ~" >>/etc/skel/.bashrc;

  mkdir -p /etc/skel/Desktop \
    && cp "$asset_folder/xfce-jbtoolbox.desktop" /etc/skel/Desktop/jbtoolbox.desktop \
    && chmod +x /etc/skel/Desktop/jbtoolbox.desktop;

  mkdir -p /etc/skel/slidewsl \
    && rsync -av "$asset_folder/../slidewsl/" /etc/skel/slidewsl;
}

set_up_user() {
  useradd "$username" --create-home -G docker
  echo "$username:$password" | chpasswd

  echo "$username ALL=(ALL) NOPASSWD:ALL" | sudo tee -a "/etc/sudoers.d/$username"
  chmod 440 "/etc/sudoers.d/$username"

  sudo -u "$username" -i sh -c "
    slidewsl/dev-admin.sh sync
  "
}

# -----------------------------------

_call() {
  func=${1:-};
  shift;
  heading "$func"
  $func "$@"
}

failed() {
  echo "Error: Command \"$BASH_COMMAND\" failed with exit code $?"
  exit 1
}

heading() {
  local title=$1 subtitle=$2 char=$3 line
  if [ -z "$char" ]; then char='@'; fi
  line=$(printf "%$((${#title}+6))s\n" | tr " " "$char")
  printf "\n\n\n%s\n%s%s %s %s%s %s\n%s\n\n\n\n" "$line" "$char" "$char" "$title" "$char" "$char" "$subtitle" "$line"
}

# -----------------------------------

trap 'failed' ERR

main "$@" > >(tee -a ~/provision.log) 2>&1
