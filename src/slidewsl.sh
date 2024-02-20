#!/bin/bash

if [ "$USER" != "root" ]; then
  echo "Error: user isn't root"
  exit 1
fi

if [ -z "$1" ]; then
  echo "Error: username was not provided"
  echo "Usage: $0 <username>"
  exit 1
fi
username="$1"

cd ~ || exit

sudo -u "$username" -i sh -c 'echo cd \~>>~/.bashrc'
dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf install -y dnf-utils zip unzip git bash-completion dbus-x11 telnet hostname

# xfce + xrdp
dnf group install -y --setopt=group_package_types="mandatory" xfce
dnf install -y xrdp xfce4-terminal xfce4-appfinder
sed -ri "s/^port=3389/port=3390/" /etc/xrdp/xrdp.ini
systemctl enable --now xrdp

# fix xrdp
# https://github.com/neutrinolabs/xrdp/issues/2491
curl -sLO https://raw.githubusercontent.com/matt335672/nest-systemd-user/ca9cd41778fafae9791b5027f261e49826566794/systemd_user_context.sh systemd_user_context.sh
chmod +x systemd_user_context.sh
mv systemd_user_context.sh /usr/libexec/xrdp
wm_fixup="if [ -x /usr/bin/systemctl -a \"\$XDG_RUNTIME_DIR\" = \"/run/user/\"\`id -u\` ]; then eval \"\`\${0%/*}/systemd_user_context.sh init -p \$\$\`\"; fi"
sed -i "/^wm_start$/i $wm_fixup" /usr/libexec/xrdp/startwm.sh
sed -ri "s#\. /etc/X11/xinit/Xsession#startxfce4#" /usr/libexec/xrdp/startwm.sh

# sshd
sed -ri "s/^#?Port .*/Port 2223/" /etc/ssh/sshd_config

# docker
dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
usermod -aG docker "$username"
systemctl enable --now docker.service
sysctl -w fs.inotify.max_user_watches=524288

# node and yarn (containerize?)
curl -fsSL https://rpm.nodesource.com/setup_14.x | grep -v '^[a-z]*_deprecation_warning$' | bash -
dnf install -y nodejs-14.20.1
npm install -g yarn@1.22.19 --no-progress

# custom hosts
sh -c 'echo -e "#!/bin/sh\\nif [[ -n \"\$1\" && -n \"\$2\" ]]; then echo \"\$2\" \"\$1\" | tee -a /etc/hosts.wsl /etc/hosts; fi" >/usr/local/bin/add-host.sh'
chmod +x /usr/local/bin/add-host.sh
touch /etc/hosts.wsl
echo cat /etc/hosts.wsl \>\>/etc/hosts >>/etc/rc.d/rc.local.wsl

# call rc.local.wsl from rc.local
echo /etc/rc.d/rc.local.wsl >>/etc/rc.d/rc.local
chmod +x /etc/rc.d/rc.local /etc/rc.d/rc.local.wsl
/etc/rc.d/rc.local.wsl

# keep distro running
cat <<EOF | sed "s/^  //" >/etc/profile.d/wsl-keepalive.sh
  #!/bin/bash

  pid_file="/tmp/wsl-keepalive.pid"
  pid=\$(cat "\$pid_file" 2>/dev/null)
  if test -z "\$pid" || ! ps -p "\$pid" >/dev/null; then
    dbus-launch true
    dbus_pid=\$(pgrep -n dbus-daemon)
    echo "\$dbus_pid" >"\$pid_file"
  fi
EOF
chmod 644 /etc/profile.d/wsl-keepalive.sh
/etc/profile.d/wsl-keepalive.sh

# browsers
dnf install -y firefox chromium

# jetbrains toolbox
dnf install -y fuse fuse-libs
curl -sLO https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.2.1.19765.tar.gz
tar -xzf jetbrains-toolbox-2.2.1.19765.tar.gz -C /opt
# add desktop shortcut
sudo -u "$username" -i sh -c 'mkdir Desktop'
sudo -u "$username" -i sh -c 'echo -e [Desktop Entry] >Desktop/jbtoolbox.desktop'
sudo -u "$username" -i sh -c 'echo -e Name=JetBrains Toolbox >>Desktop/jbtoolbox.desktop'
sudo -u "$username" -i sh -c 'echo -e Comment=Install JetBrains Toolbox >>Desktop/jbtoolbox.desktop'
sudo -u "$username" -i sh -c 'echo -e Version=1.0 >>Desktop/jbtoolbox.desktop'
sudo -u "$username" -i sh -c 'echo -e Icon=applications-development >>Desktop/jbtoolbox.desktop'
sudo -u "$username" -i sh -c 'echo -e Type=Application >>Desktop/jbtoolbox.desktop'
sudo -u "$username" -i sh -c 'echo -e Terminal=false\\n >>Desktop/jbtoolbox.desktop'
sudo -u "$username" -i sh -c 'echo -e Exec=/opt/jetbrains-toolbox-2.2.1.19765/jetbrains-toolbox >>Desktop/jbtoolbox.desktop'
sudo -u "$username" -i sh -c 'chmod +x Desktop/jbtoolbox.desktop'

# truncate -s 10G /mnt/d/database.vhd
# mkfs.ext4 /mnt/d/database.vhd
# mkdir /mnt/database
# mount -o loop /mnt/d/database.vhd /mnt/database
# sh -c 'echo /mnt/d/database.img /mnt/database ext4 loop 0 0 >>/etc/fstab'

echo -ne "\nDocker test: "
if docker version 2>/dev/null 1>&2; then echo -e ok\\n; else echo -e not ok\!\!\!\!\!\!\!\!\!\!\!\!\\n; fi
