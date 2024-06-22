<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Basic walkthrough](#basic-walkthrough)
- [Development environment](#development-environment)
- [Graphical interface](#graphical-interface)
- [Customizations](#customizations)
- [Virtual disk image](#virtual-disk-image)
- [SlideWSL for Production](#slidewsl-for-production)
- [Q&A](#qa)
- [IntelliJ](#intellij)
  - [Options](#options)
  - [Settings](#settings)
  - [Debugging](#debugging)
  - [Laravel](#laravel)
- [Miscellaneous](#miscellaneous)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

<!-- doctoc NOTES.md --github -->


### Basic walkthrough

- Steps:
    - Install SlideWSL
    - Create a starter app
    - Launch nginx, PHP-FPM/Laravel, KeyDB, MySQL, and phpMyAdmin
    - Launch the webpack dev server
    - Tail the logs
- Here's a block you can copy/paste:
  ```bash
  docker compose run --rm angular starter example \
    && docker compose run --rm php starter \
    && docker compose up -d \
    && APPS="example" docker compose up --force-recreate angular-dev-server -d \
    && docker compose logs -f
  ```
  But, if you already have a project in place, you'd skip the _starter_ steps and add a _build_ step like this:
  ```bash
  docker compose up -d \
    && docker compose run --rm angular build my-project \
    && APPS="my-project" docker compose up --force-recreate angular-dev-server -d \
    && docker compose logs -f
  ```
- Update the Windows `hosts` file:
  ```text
  127.0.0.1 local.example.com
  ```
- Visit the example site:
    - nginx: https://local.example.com (bypass self-signed cert warning)
    - webpack dev server: http://local.example.com:4201
    - phpMyAdmin (user/pass: root/root): http://localhost:8080/

---

```text
C:\SlideWSL>getslidewsl dave mypassword
user: dave
OracleLinux_8_7 already exists. do you wish to delete it?
Enter Y or N: [Y,N]?Y

<snip>

----------------------------------------------------------

 Done!

 Start: 06:50:47.96
 End  : 06:54:08.07

 Now run  Windows Remote Desktop  (mstsc.exe)
 Use the computer location: localhost:3390
 Username: dave (and the password you provided)

 Or, for a terminal: wsl or oraclelinux87
 Or, for ssh: ssh dave@localhost -p 2223

----------------------------------------------------------


C:\SlideWSL>wsl
|
| Welcome to the SlideWSL development environment!
|
| <snip>
|


[dave@wsl ~]$ docker compose run --rm angular starter example
generating application: example
yarn run v1.22.19
Packages installed successfully.
building with: ng build example --base-href=/
Initial Chunk Files           | Names         |  Raw Size | Estimated Transfer Size
main.6024eba3a956365b.js      | main          | 173.64 kB |                46.40 kB
polyfills.9acd7e87ef537323.js | polyfills     |  33.08 kB |                10.64 kB
runtime.92c8b83a3d996273.js   | runtime       | 892 bytes |               506 bytes
styles.ef46db3751d8e999.css   | styles        |   0 bytes |                       -
                              | Initial Total | 207.59 kB |                57.53 kB


[dave@wsl ~]$ docker compose run --rm php starter
Created project in /laravel/.
Updating dependencies
Publishing complete.


[dave@wsl ~]$ docker compose up -d
✔ Container keydb-node3       Started
✔ Container keydb-node2       Started
✔ Container slidewsl-init0-1  Exited
✔ Container keydb-node1       Started
✔ Container slidewsl-init-1   Started
✔ Container mysql             Started
✔ Container phpmyadmin        Started
✔ Container php-fpm           Started
✔ Container nginx             Started


[dave@wsl ~]$ APPS="example" docker compose up --force-recreate angular-dev-server -d
✔ Container angular-dev-server Started


[dave@wsl ~]$ docker compose logs -f
<snip>
^C canceled

[dave@wsl ~]$
```


### Development environment

Type `dev` (an alias for `~/slidewsl/dev-admin.sh`) to see a list of commands.

Currently, this entails running Docker Compose commands directly as it is the most
flexible and educational. But, the dev command itself might be beefed up to wrap
some of the more common tasks. Currently, for example, there are commands like
`dev list` and `dev reset`.

<img alt="screenshot" src="./devhelp.png" width="500" />

### Graphical interface

A lightweight XFCE desktop is accessible by connecting to _localhost_ from
a remote desktop client such as Microsoft Remote Desktop or FreeRDP. You won't
need an X11 server (such as VcXsrv or Xming) running on the Windows host.
This comes with JetBrains Toolbox, plus Firefox and Chromium.
These can also be executed from the terminal using WSLg (be sure to log out of XFCE first).

<img alt="screenshot" src="./slidewsl.png" width="500" />


### Customizations

In order to give the developer full control, this project aims to both provision the WSL2 distro on-demand, and to build all images locally.
To take advantage of customization capabilities:

- Clone this repo to your Windows host (i.e., safely outside of the WSL2 distro).
- Place `sync.sh` in your repo's `local` folder. You'll find an example sync script in the local folder.
  - During a fresh install of SlideWSL, pass the location of your script: `getslidewsl myusr mypswd ..\local\sync.sh`
  - If you forget, you can start using after installation by copying your script into place,
    for example: `cp /mnt/c/users/dave/Desktop/git/slidewsl/local/sync.sh ~/slidewsl`.
- Run `dev sync` in WSL2 whenever you have changes to deploy.
  - If found, it copies `~/slidewsl/sync.sh` to `/tmp` for execution.
     And, on return, if the timestamp of `~/slidewsl/sync.sh` changed, it runs again with the updated version.
- The `sync.sh` script can be used to, for example, pick up changes to Dockerfiles, .env files, container scripts, and service configs.
  It might include the following:
  - `rsync` your `src/assets/slidewsl` folder to `~/slidewsl`.
  - Create a custom `local.env` to specify your _web_, _angular_, _laravel_, and _db_ folders;
    change exposed ports using `ANGULAR_DEV_SERVER_PORT_RANGE`, `NGINX_SECURE_PORT`, and `PHPMYADMIN_PORT`;
    modify versions of Angular and PHP.
  - Write a replacement `dev-server.conf` to map apps to custom `ng serve` commands.
  - Add support for browscap by copying an _.ini_ file to `~/slidewsl/php/etc`.
  - Run `dos2unix` or other tools.
  - Regenerate your Compose YAML files.
- This is less common, but you can also run multiple Compose projects simultaneously using the same YAML file
with individual configurations that specify different source code, tools, and ports (perhaps to run a legacy
stack while migrating). Simply prefix your Docker commands with these variables:
  - `COMPOSE_ENV_FILES`, `COMPOSE_PROJECT_NAME`, and `CONF_FILENAME`
  - For example:
    ```bash
    COMPOSE_ENV_FILES=$HOME/slidewsl/_env/local-legacy.env COMPOSE_PROJECT_NAME=slidewsl-legacy docker compose up -d --build
    COMPOSE_ENV_FILES=$HOME/slidewsl/_env/local-legacy.env COMPOSE_PROJECT_NAME=slidewsl-legacy CONF_FILENAME=dev-server-legacy.conf APPS="my-app" docker compose up --force-recreate angular-dev-server -d
    ```
- To customize the `getslidewsl.bat` batch file itself (perhaps to build an enhanced WSL2 distro),
  it's easiest to do that build from a different (non-SlideWSL) WSL2 distro,
  for example: `wsl -d ubuntu /mnt/c/users/dave/Desktop/git/slidewsl/build.sh`.


### Virtual disk image

The installation process creates a sparse virtual hard disk image (using qemu-img
  in the qcow2 format).
  It's intended to be used for project and local database files.
  The disk image can be disconnected in order to rebuild the underlying
  WSL2 host; it can then be seamlessly reattached without loss of data
  or configuration (such as local changes, branches, and shelved items).
- The image file is created at `%userprofile%\slidewsl.img`
  and mounted at `/mnt/slidewsl`.
  It's set to grow to a max size of 20G (currently hard-coded in `disk-image.sh`).
- The `.angular` folder can quickly chew up lots of space. Either disable cli caching or purge this folder periodically.
- Symlinks (such as from $HOME to /mnt) are possible, but currently not advised.
- The mount is controlled by the `disk-image` systemd service.
- To unmount for backup or rebuild:
  - Use `sudo systemctl stop disk-image`, then `exit`, and `wsl --shutdown`.
  - Be sure to stop IntelliJ first, because:
    - It will attempt to create files under the mount folder when the image isn't mounted.
    - It can also create files as root before the default user is set, thereby causing user provisioning to fail.
  - Bring down Docker containers first, or their processes might be killed when unmounting.
- It's unclear if systemd shuts down gracefully when Windows shuts down or reboots:
  [8939](https://github.com/microsoft/WSL/discussions/11225),
  [11225](https://github.com/microsoft/WSL/issues/8939).

Additional Ideas:
- One interesting idea is to point `DOCKER_BUILDKIT_CACHE` at the disk image to speed
  things up after rebuilding WSL2.
- Similarly, another is to set `HISTFILE` to store `.bash_history` in the disk image.
- Consider exporting your IntelliJ settings to the disk image so they can be imported
  when recreating the WSL2 instance.

<details>
<summary>It's a little involved, but it's possible to increase the size of an existing disk image</summary>

  ```bash
  # Shut everything down
  source /etc/disk-image.conf
  echo image: $IMG_LOCATION
  docker compose --profile "*" down -v
  df -h /mnt/slidewsl | grep /dev/nbd0
  sudo systemctl stop disk-image
  sudo qemu-img info $IMG_LOCATION
  # Back up the image file now before continuing
  # Resize the image file
  sudo qemu-img resize $IMG_LOCATION +10G # specify increase
  sudo qemu-nbd --connect=/dev/nbd0 "$IMG_LOCATION"
  sudo e2fsck -f /dev/nbd0
  sudo resize2fs /dev/nbd0
  sudo e2fsck -f /dev/nbd0
  lsblk -l /dev/nbd0
  sudo qemu-nbd --disconnect /dev/nbd0
  sudo qemu-img info $IMG_LOCATION
  sudo systemctl start disk-image
  df -h /mnt/slidewsl
  ```
</details>

### SlideWSL for Production

This is a rough draft to outline the steps involved.

<details>
<summary>Ensure the root of your Angular project includes a .dockerignore</summary>

```dockerignore
node_modules
dist
.angular
README.md
```
</details>

<details>
<summary>Sync your repo with the WSL2 instance, rebuild the YAML, and copy updates back to your workspace</summary>

```bash
root=/mnt/c/users/dave/Desktop/git/slidewsl
dev sync
```
</details>

<details>
<summary>Set the TAG environment variable, build the build image, then build the rest</summary>

```bash
docker context use default
export TAG=my-tag01
BUILD_TAG=$TAG APP_NAME=my-project docker compose -f ~/slidewsl/compose.build.yaml --env-file=~/slidewsl/_env/build.env build build
BUILD_TAG=$TAG APP_NAME=my-project docker compose -f ~/slidewsl/compose.build.yaml --env-file=~/slidewsl/_env/build.env build
```
</details>

<details>
<summary>Launch a local registry, tag the build, push, and list the registry content</summary>

```bash
docker network create registry-net
docker run -d -p 5000:5000 --network=registry-net --name registry registry:2
docker tag deploy-angular-ssr:$TAG localhost:5000/deploy-angular-ssr:$TAG
docker tag deploy-mysql:$TAG localhost:5000/deploy-mysql:$TAG
docker tag deploy-keydb-node1:$TAG localhost:5000/deploy-keydb-node1:$TAG
docker tag deploy-keydb-node2:$TAG localhost:5000/deploy-keydb-node2:$TAG
docker tag deploy-keydb-node3:$TAG localhost:5000/deploy-keydb-node3:$TAG
docker tag deploy-phpmyadmin:$TAG localhost:5000/deploy-phpmyadmin:$TAG
docker tag deploy-php-fpm:$TAG localhost:5000/deploy-php-fpm:$TAG
docker tag deploy-nginx:$TAG localhost:5000/deploy-nginx:$TAG
docker push localhost:5000/deploy-angular-ssr:$TAG
docker push localhost:5000/deploy-mysql:$TAG
docker push localhost:5000/deploy-keydb-node1:$TAG
docker push localhost:5000/deploy-keydb-node2:$TAG
docker push localhost:5000/deploy-keydb-node3:$TAG
docker push localhost:5000/deploy-phpmyadmin:$TAG
docker push localhost:5000/deploy-php-fpm:$TAG
docker push localhost:5000/deploy-nginx:$TAG
local-registry-list.sh|egrep "$TAG|Repo"
```
</details>

<details>
<summary>Launch the staging container, prepare SSH, and create the Docker Context</summary>

```bash
docker build -t staging ~/slidewsl/staging --build-context shared=~/slidewsl/shared
docker run --name staging --network=registry-net --privileged --rm -u root -d -p 2375:2375 -p 2222:22 -p 8090:8080 -p 4450:443 staging

ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa
ssh-keygen -R [localhost]:2222
ssh-copy-id -i ~/.ssh/id_rsa.pub root@localhost -p 2222 # the password is 'password'

docker context create staging --docker "host=ssh://root@localhost:2222"
```
</details>

<details>
<summary>Deploy the stack</summary>

```bash
docker context use staging
docker swarm init
REGISTRY=registry:5000/ BUILD_TAG=$TAG docker stack deploy -d -c ~/slidewsl/compose.staging.yaml my-stack
docker stack services my-stack
docker service ps my-stack_angular-ssr --no-trunc # and others
docker service logs my-stack_nginx -f # and others
docker ps
# test phpmyadmin at https://localhost:4450
# test website at http://localhost:8090
# be sure to return to the default context as needed
docker context use default
```
</details>

<details>
<summary>Redeploy</summary>

Now that the registry and staging containers are up, this only requires a subset of steps:

```bash
dev sync
docker context use default
export TAG=my-tag02
# build the build image and the rest
# tag and push
docker context use staging
REGISTRY=registry:5000/ BUILD_TAG=$TAG docker stack deploy -d -c ~/slidewsl/compose.staging.yaml my-stack
docker context use default
```
</details>



### Q&A

- What is the _init_ service?

  If a volume source doesn't exist, the daemon creates it and makes _root_ the owner. To
  deal with this, some services depend on an _init_ service to ensure folders are properly
  created and writable. There are two `init` services so that other services can depend on
  that one and let it deal with service_completed_successfully.

- How can I debug nginx problems?

  Change the nginx Dockerfile to run `nginx-debug` and change nginx.conf to
  enable debug logging with `error_log  /var/log/nginx/error.log debug;`.

- (This no longer applies) ~~Why both `compose.yaml` and `compose-slidewsl.yaml`?~~

  _env_file_ runs after bind mounting, so it can't be used to override variables in
  _.env_. To address this, `compose.yaml` uses "include" because its `env_file` seems
  to work in overriding before `compose-slidewsl.yaml` is added.

- How can I use Angular SSR locally?

  Both the older ssr-dev-server builder (`serve-ssr`) and the newer unified dev server
  will work great as-is.
  (The former currently works better because of [26323](https://github.com/angular/angular-cli/issues/26323)).
  Be sure to adjust your angular.json and the dev-server.conf
  command as needed.

  The tricky part is when testing our app in a way that more closely resembles production.
  Of course, you could do a full deployment to the staging container.
  But, if you'd like to test in the local dev environment,
  here's a summary of the steps to get you started:

  - Set `SSR_ENABLED` to true in local.env.
    (If using the sync script approach, be sure to sync this change.)
  - Create a _new_ starter app and hosts entry as described in the walkthrough: `docker compose run --rm angular starter example2`.
  - Restart nginx: `docker compose up -d --force-recreate nginx`.
  - Launch the ssr container: `APP=example2 docker compose up -d --force-recreate angular-ssr`.
  - If you see gateway errors, ensure the ssr container is running and the domain name matches the project/dist folder name.

- Woah! Where's my disk space?!

  This stuff uses a ton.
  Simply deleting containers and images (such as using `dev reset`) won't cause WSL2
  to release the space.
  You could export/import your WSL2 instance in order to move it to a larger disk.
  You could also recreate the whole thing (getslidewsl.bat).
  Short of that, you'll need to stop your containers (`docker compose --profile "*" down -v` and any others),
  exit IntelliJ,
  unmount the disk image (`sudo systemctl stop disk-image`),
  and shut down WSL2 (`wsl --shutdown`).
  Then, find your VHD, for example:

  `C:\Users\<YourUsername>\AppData\Local\Packages\<DistroPackage>\LocalState\ext4.vhdx`

  (The distro package might include OracleAmericaInc.)

  Now use diskpart (at your own risk!):

  ```
  diskpart
  select vdisk file="<path_to>\ext4.vhdx"
  attach vdisk readonly
  compact vdisk
  detach vdisk
  exit
  ```

### IntelliJ

#### Options

IntelliJ can be launched multiple ways.
Choices 1 and 2 are recommended as they allow for the best performance, and you can easily
switch between them to pick up where you left off (you must log out of XFCE to use WSLg).

1. **From Linux Over WSLg**: This would be the clear winner if not for the added window frame that comes with WSLg
   (see [530](https://github.com/microsoft/wslg/issues/530), [166](https://github.com/microsoft/wslg/issues/166)).
   To install JetBrains Toolbox, run `/opt/jetbrains-toolbox-2.2.1.19765/jetbrains-toolbox`.
   Afterward, use `~/.local/share/JetBrains/Toolbox/bin/jetbrains-toolbox >/dev/null 2>&1 &`.
   To launch IntelliJ directly, `find ~/. -name idea.sh` will show the file to launch, such as:
   `~/.local/share/JetBrains/idea-IU-241.17890.1/bin/idea.sh >/dev/null 2>&1 &` or
   `~/.local/share/JetBrains/Toolbox/apps/intellij-idea-ultimate/bin/idea.sh >/dev/null 2>&1 &`.
   Tip: Exit using the Quit menu option instead of clicking X.
   Open your project under `/mnt/slidewsl`, such as `/mnt/slidewsl/dave/src`.

2. **From XFCE using RDP**: The XFCE option is nice if you want to develop while fully immersed in an isolated desktop environment that
   includes XFCE bells and whistles. Simply run your favorite remote desktop tool and connect to `localhost:3390`.
   There, you will find a JetBrains Toolbox shortcut on the desktop to do the IntelliJ install.
   Unlike with option 1, you can get a true full screen IDE (alt-F11) or scale the entire desktop based on the size of the RDP window.
   But, you may run into some issues. For example, if you use ctrl-F3 for something in the IDE, it might be intercepted by XFCE and the
   workspace switcher (to jump to workspace #3). A fix is to remove the `workspace_3_key` entry in
   `~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml`.

3. **From JetBrains Gateway**: (ie, Remote Development) Lots of issues, but JetBrains is improving this.

4. **From Windows**: This works OK. In fact, you can run 3 alongside 1 or 2. But, unfortunately, it will be slower for
   things like indexing dependencies or linting TypeScript files. Open your project using `\\wsl$\OracleLinux_8_7\mnt\slidewsl`.

#### Settings

These are suggested IntelliJ settings. After applying, consider exporting your settings to the disk image under /mnt/slidewsl (or to your JetBrains account) so they can be imported when recreating the WSL2 instance:

- `File | Settings | Plugins`
  - Install PHP, PHP Docker, GitToolBox, Blade
- `File | Settings | Languages & Frameworks | PHP`
  - Set the language level
  - Set CLI interpreter:
    - Add a new entry "From Docker"
    - Select the "Docker Compose" radio button
    - Set the configuration file to `/home/{name}/slidewsl/compose.local.yaml` (update the name)
    - Set the service to "php", with "always start a new container"
    - Note that older versions of IntelliJ had problems using Compose
  - Set path mappings (for phpunit tests):
    - Map your local project path (the value of SLIDEWSL_LARAVEL_ROOT_IN_WSL) to /app/laravel
- `File | Settings | Languages & Frameworks | Node.js`
  - Set Node interpreter:
    - Add a new remote entry
    - Docker Compose
    - Configuration file `/home/{name}/slidewsl/compose.local.yaml`
    - Set service "angular"
- `File | Settings | Languages & Frameworks | TypeScript`
  - Use types from server
  - Set Node interpreter, choose the entry from above: docker-compose://[compose.local.yaml]:angular/node
- `File | Settings | Languages & Frameworks | PHP | Quality Tools | PHP CS Fixer`
  - Be sure to set to "on" and choose "php" (as created above) with path `/tools/vendor/friendsofphp/php-cs-fixer/php-cs-fixer`
- `File | Settings | Languages & Frameworks | PHP | Servers`
  - Map the value of SLIDEWSL_LARAVEL_ROOT_IN_WSL to `/laravel`
- Fix for launching Windows Explorer from WSLg:
  - Run: `sudo sh -c 'echo "/mnt/c/Windows/explorer.exe \\\\\\\\wsl\\\$\\\\OracleLinux_8_7\"\$1\" &" > /sbin/explorer && chmod +x /sbin/explorer'`
  - Run: `xfce4-mime-settings &`
  - Under Utilities, set File Manager to ("Other...") `/sbin/explorer "%s"`

<details>
<summary>Optional settings</summary>

These are other kinds of settings you may want to review:

- `File | Settings | Appearance & Behavior | New UI`
  - Disable new UI
- `File | Settings | Plugins`
- `File | Settings | Appearance & Behavior | Appearance`
  - Install and use Dark Purple theme
- `File | Settings | Version Control | GitToolBox`
  - Disable editor inline blame
- `File | Settings | Editor | Code Style | PHP | Code Generation`
  - Uncheck "line comment", check "Add a space"
- `File | Settings | Editor | General | Editor Tabs`
  - Tab limit: 50 (?)
- `File | Settings | Keymap`
  - Choose a predefined base, such as Windows, then customize:
    - "Switcher", add Alt+D
    - "Close tab", add Ctrl+Alt+W
    - "Show in explorer" (file manager), Ctrl+Alt+Shift+E
    - "Show history" (version control systems), Alt+Shift+Y
    - "Next occurrence of the word at caret", Ctrl+F3
    - "Move to next occurrence", Ctrl+K
    - "Move to previous occurrence", Ctrl+Shift+K
    - "Go to declaration and usages" (mouse shortcut), Middle-Click
    - "Show Source" (main Menu, view), remove Ctrl+Enter
- `File | Settings | Editor | General | Smart Keys`
  - Use CamelHumps words [check]
  - Honor CamelHumps words settings [uncheck]
- `Editor | Code Style | TypeScript | Punctuation`
  - Use single quotes
- `File | Settings | Version Control | Commit`
  - Use non-modal commit interface [uncheck]
  - Enable all inspections, limit subject line: 50
- `File | Settings | Editor | General`
  - Scroll, move caret, minimize editor scrolling
</details>


#### Debugging

  If using options 1 or 2 as listed above, Xdebug should connect to IntelliJ without any issues.
  If using option 4, Xdebug will use the _WSL2 gateway IP address_ as specified in php.ini:
    `xdebug.client_host=${WSL2_GATEWAY}`. You may need to update the Windows Defender firewall
    as described in [4139](https://github.com/microsoft/WSL/issues/4139), [11139](https://github.com/microsoft/WSL/issues/11139), and from [JetBrains](https://www.jetbrains.com/help/idea/how-to-use-wsl-development-environment-in-product.html#debugging_system_settings).
    Run these commands from an elevated PowerShell when the WSL2 distro is created or recreated, or when upgrading IntelliJ:

  ```powershell
  New-NetFirewallRule -DisplayName "WSL" -Direction Inbound -InterfaceAlias "vEthernet (WSL)" -Action Allow
  Get-NetFirewallProfile -Name Public | Get-NetFirewallRule | where DisplayName -ILike "IntelliJ IDEA*" | Disable-NetFirewallRule
  ```

  To debug Angular, create a JavaScript Debug Run/Debug configuration in IntelliJ with your URL.
  Set the browser path if necessary, for example: `/usr/bin/chromium-browser`.

#### Laravel

  - Browser requests to `/api` are routed to Laravel's `public/index.php`.
  - Your angular project may require a `proxy.conf.json` similar to:
    ```json
    {
      "/api/": {
        "target": "https://nginx:4430",
        "secure": false,
        "changeOrigin": false
      }
    }
    ```

### Miscellaneous

- The output from WSL2 provisioning can be viewed with `sudo less /root/provision.log`.

- WSL2 Export/Import

  - You could [export](https://learn.microsoft.com/en-us/windows/wsl/basic-commands#export-a-distribution) and import your WSL2 distro for repeat installs.

  - Advanced: This could also be used to run multiple SlideWSL environments
    at once (ie: multiple WSL distros). But, be very careful not to mount the same disk image
    concurrently. Hint: Different locations should be specified in
    `/etc/disk-image.conf`. The systemd service is `disk-image`.
    A better solution is running multiple Compose projects as mentioned elsewhere.

  - Sample DOS commands for export/import:

    ```dosbatch
    set wsl_path=%userprofile%\Desktop\wsl
    set origin_distro=OracleLinux_8_7
    set second_distro=OracleLinux_8_7_Legacy
    mkdir %wsl_path% 2>nul
    cd %wsl_path%
    mkdir images 2>nul
    mkdir instances 2>nul
    wsl --export %origin_distro%                           images\slidewsl_wsl_distro.tar
    wsl -l -v
    wsl --import %second_distro% instances\%second_distro% images\slidewsl_wsl_distro.tar
    wsl -l -v
    echo now run: wsl -d %second_distro%
    ```

- For LAN access over RDP, adjust firewalls as needed and create a port forward for Windows
using commands like:

  ```dosbatch
  wsl -e sh -c "ip route show | grep -i default | awk '{ print $3}'"
  netsh interface portproxy add v4tov4 listenport=3390 listenaddress=0.0.0.0 connectport=3390 connectaddress=<ip>
  netsh interface portproxy show all
  netsh interface portproxy delete v4tov4 listenport=3390 listenaddress=0.0.0.0
  ```

- You may want to copy your existing .ssh folder into the WSL2 distro, such as:

  ```bash
  cp /mnt/c/Users/<name>/.ssh/id_* ~/.ssh
  cp /mnt/c/Users/<name>/.ssh/config ~/.ssh
  chmod 600 ~/.ssh/config ~/.ssh/id_*
  export OTHER_SECURITY_TOKENS=value
  ```

- Why drvfs is slow:
  - https://github.com/microsoft/WSL/issues/873#issuecomment-425272829
  - https://github.com/microsoft/WSL/issues/4197#issuecomment-604592340
  - plan9/9p https://en.wikipedia.org/wiki/9P_(protocol)
  - plan9/9p https://superuser.com/questions/1643551/windows-10-wsl-mount-creates-9p-filesystem-instead-of-drvfs

- [Synchronized file shares](https://docs.docker.com/desktop/synchronized-file-sharing/)

- WSL2 best practices:
  - https://www.docker.com/blog/docker-desktop-wsl-2-best-practices/
  - https://docs.docker.com/desktop/wsl/best-practices/
  - https://learn.microsoft.com/en-us/windows/wsl/setup/environment
