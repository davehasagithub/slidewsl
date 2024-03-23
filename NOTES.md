# Notes

_This page includes random notes that could one day become proper documentation._

### Development environment

<img alt="screenshot" src="./devhelp.png" width="500" />


### Graphical interface

<img alt="screenshot" src="./slidewsl.png" width="500" />

  A lightweight XFCE desktop is accessible by connecting to _localhost_ from
    a remote desktop client such as Microsoft Remote Desktop or FreeRDP. You won't
    need an X11 server (such as VcXsrv or Xming) running on the Windows host.
  This comes with JetBrains Toolbox, plus Firefox and Chromium.

 
### Customizations

  During installation, the Docker assets found in `src/assets/docker` will be copied to `/docker`
    in the root of the WSL2 distro (or, more specifically, they are expanded from the
    encoded chunks in `getslidewsl.bat`).
  
  If you're interested in making customizations, one approach is to clone this repo to your
    Windows host (i.e., outside of the WSL2 distro).
  - Run `dev sync` in WSL2, and, if found, it will run `/docker/sync.sh`.
    - During a fresh install of SlideWSL, pass the location of your script:
      `getslidewsl myusr mypswd ..\local\sync.sh`
    - To begin using after installation, copy your script from, for example, `/mnt/c/path/repo/local`, to `/docker`.
  - Place `sync.sh` in your repo's `local` folder. When `dev sync` runs, it copies `/docker/sync.sh` to `/tmp`
    for execution. On return, if the timestamp of `/docker/sync.sh` changed, it runs again.
  - Example things to do in `sync.sh`:
    - `rsync` your `/src/assets/docker/` folder to `/docker` (with `--delete`).
    - Use `docker-custom.env` to override `docker-base.env` with your own _web_, _angular_, _laravel_, and _db_ root folders.
    - Use `docker-php.env` to set `APP_ENV` for your laravel app.
    - Write a replacement `dev-server.conf` to map apps to your `ng serve` commands.
    - Add support for browscap by copying an _.ini_ file to `/docker/php/conf`.
    - Use `docker-phpmyadmin.env` to define `PMA_USER` and `PMA_PASSWORD`.
    - Run `dos2unix` if necessary.

### IntelliJ

#### PHP

  - Use the PHP Docker plugin in IntelliJ to work remotely with the PHP CLI from the _slidewsl-php-fpm_ Docker container.
  - Enable PHP CS Fixer using the same container and the path: `/tools/vendor/friendsofphp/php-cs-fixer/php-cs-fixer`

#### Debugging

  - In order to debug using IntelliJ with WSL2 and Xdebug,
the WSL2 distro assigns the _WSL2 gateway IP address_ to a variable.
  - This variable is used in php.ini to allow the php-fpm container to connect to the IDE:
`xdebug.client_host=${WSL2_GATEWAY}`.

  - You may run into the following issues:
  [4139](https://github.com/microsoft/WSL/issues/4139),
  [11139](https://github.com/microsoft/WSL/issues/11139).

  - More details from [JetBrains](https://www.jetbrains.com/help/idea/how-to-use-wsl-development-environment-in-product.html#debugging_system_settings).

  - Your experience might be different if you're using WSL2 _mirrored_ networking.

  - The workaround involves updates to the Windows Defender Firewall:

    ```powershell
    # From elevated PowerShell
    New-NetFirewallRule -DisplayName "WSL" -Direction Inbound -InterfaceAlias "vEthernet (WSL)" -Action Allow
    Get-NetFirewallProfile -Name Public | Get-NetFirewallRule | where DisplayName -ILike "IntelliJ IDEA*" | Disable-NetFirewallRule
    ```

### Laravel

  - Browser requests to `/api` are routed to Laravel's `public/index.php`.
  - Update Angular's `proxy.conf.json` as shown here:
    ```json
    {
      "/api/": {
        "target": "https://nginx:4430",
        "secure": false,
        "changeOrigin": false
      }
    }
    ```
  - For debugging in IntelliJ, map the value of `SLIDEWSL_LARAVEL_ROOT_IN_WSL` to `/laravel`
    under `Settings | Languages & Frameworks | PHP | Servers`.

### Miscellaneous

- The output from WSL2 provisioning can be viewed with `sudo less /root/provision.log`.

- You could [export](https://learn.microsoft.com/en-us/windows/wsl/basic-commands#export-a-distribution) your WSL2 distro for repeat installs.

- For LAN access over RDP, adjust firewalls as needed and create a port forward for Windows
using commands like:

  ```dosbatch
  wsl -e sh -c "ip route show | grep -i default | awk '{ print $3}'"
  netsh interface portproxy add v4tov4 listenport=3390 listenaddress=0.0.0.0 connectport=3390 connectaddress=<ip>
  netsh interface portproxy show all
  netsh interface portproxy delete v4tov4 listenport=3390 listenaddress=0.0.0.0
  ```

- You may want to copy your .ssh folder into the WSL distro, such as:

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

- Hints on attaching an ext4 file system in WSL2:

  ```bash
  truncate -s 10G /mnt/d/database.vhd
  mkfs.ext4 /mnt/d/database.vhd
  mkdir /mnt/database
  mount -o loop /mnt/d/database.vhd /mnt/database
  sh -c 'echo /mnt/d/database.img /mnt/database ext4 loop 0 0 >>/etc/fstab'
  ```

- WSL2 best practices:
  - https://www.docker.com/blog/docker-desktop-wsl-2-best-practices/
  - https://docs.docker.com/desktop/wsl/best-practices/


### Walkthrough

This is a basic representative walkthrough:

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
      && APPS="example" docker compose up --force-recreate angular_dev_server -d \
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
| Redisplay this info   dev  (or /docker/dev-admin.sh)
|
| Launch environment   docker compose up -d
| Webpack dev server   APPS="<app> [...]" docker compose up --force-recreate angular_dev_server -d
| Tail the logs        docker compose logs -f
| Build an angular app docker compose run --rm angular build <app> [<base-href> [<other-args...>]]
|
| See what's running   docker compose ps
| Stop environment     docker compose down
| Update node_modules  docker compose run --rm angular node_modules
| Update composer      docker compose run --rm php composer
| Interactive terminal docker compose exec -it -u root <service> bash
| Tail laravel log     docker compose exec php-fpm tail -f /laravel/storage/logs/laravel_line-202x-xx-xx.log
| Install in container apt update; apt install -y iputils-ping telnet vim less
| Make angular starter docker compose run --rm angular starter <app>
| Make laravel starter docker compose run --rm php starter
| Check keydb cluster  docker compose exec -it keydb-node1 keydb-cli cluster info
| Rebuild services     docker compose down --rmi all --remove-orphans -v && docker compose build --no-cache
| Run sync.sh script   /docker/dev-admin.sh sync
| See Docker resources /docker/dev-admin.sh list [stats]
| Reset                /docker/dev-admin.sh reset [cache]
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


[dave@wsl ~]$ APPS="example" docker compose up --force-recreate angular_dev_server -d
✔ Container angular_dev_server Started


[dave@wsl ~]$ docker compose logs -f
<snip>
^C canceled

[dave@wsl ~]$
```
