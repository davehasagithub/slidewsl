# Notes

_This page includes random notes that could one day become proper documentation._

### Miscellaneous

- The graphical environment:
  - A lightweight XFCE desktop is accessible by connecting to _localhost_ from
      a remote desktop client such as Microsoft Remote Desktop or FreeRDP. You won't
      need an X11 server (such as VcXsrv or Xming) running on the Windows host.
  - This comes with JetBrains Toolbox, plus Firefox and Chromium.
  - <img alt="screenshot" src="./slidewsl.png" width="500" height="281" />

- The devcontainer:
  - As developers, we want to keep the WSL2 distro light, while also having a
  consistent and reproducible environment for all of our tools and dependencies.
  To achieve these goals:

    - SlideWSL installs Docker on the WSL2 host, along with
      Docker configuration files, container contexts,
      a convenient admin script, and, of course, Git.
    - We use Compose to launch the devcontainer (and other containers).
    - The service entry for the devcontainer in
      the Compose YAML grants it read-only access to the
      Docker assets through a bind mount; this allows it to
      build and orchestrate all other containers.
    - The devcontainer communicates with the Docker daemon running
      in the WSL2 distro by connecting through a port managed by _socat_ that
      relays into the privileged Docker socket.
    - Local customizations can be achieved through an optional script that
      runs when initializing the devcontainer.
  - The devcontainer includes support for Angular. You can perform a one-off installation of
    node_modules, a build of the app, or launch webpack
    dev servers.
    - You will need to create `.env.override` to override `SLIDEWSL_ANGULAR_ROOT`
    and edit `angular-dev-server.conf.sh` for your projects.
    - If a project doesn't exist, a demo starter app will be created.
    - There is no admin script for this stuff yet. Refer to [motd](src/assets/docker/devcontainer/context/motd) for current commands.


- The output from WSL2 provisioning can be viewed with `sudo less /root/provision.log`.

- User and group identifiers:

  `getslidewsl.bat` allows you to specify the uid/gid for the WSL distro (the defaults are 1000/1000).
  The same uid/gid will be used when creating the non-root user in the devcontainer.

  All other containers will also use this user ID and group ID.
  They will utilize [fixuid](https://github.com/boxboat/fixuid) to remap the original
  non-root user that was used during the container's creation.

- What is sync.sh?

  - When building or reattaching to the devcontainer, one might want to
  do prep work or customizations, such as adding or updating file assets, or doing conversions
  such as dos2unix:
    - So, before launching the devcontainer (or, actually, first thing whenever the script is called),
    `run.sh` checks to see if a script called `sync.sh` exists in
    the same folder as itself.
    (Remember, `run.sh` is the underlying script called when using the `dc` alias.)
    - If so, it runs it. And, on return, if `run.sh` finds that the timestamp on `run.sh` (itself) or
    `sync.sh` has changed, it restarts.
  - The `.gitignore` file for this project includes `local/`. Place
  customizations here and let `sync.sh` move them into position.
  Consider, for example, a custom `motd` or `.env.override`, or an updated `angular-dev-server.conf.sh`.
  In fact, store your `sync.sh` script there, too.
  - Your sync script can be placed during the initial install via
  an argument to getslidewsl.bat.

### More

- Remember you could [export](https://learn.microsoft.com/en-us/windows/wsl/basic-commands#export-a-distribution) your WSL distro for repeat installs.

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
    export ANY_SECURITY_TOKENS=value
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

- This is a basic walkthrough:
  - Install SlideWSL
  - Launch the devcontainer
    - Start the web server
  - Exit back to WSL (atypical, just as an example)
    - Install a text-based browser
    - Visit the nginx welcome page
  - Return to the devcontainer
    - Start the Angular dev server
      - A starter app will be installed because no project exists
  - Exit back to WSL again (atypical)
    - Dump source for the starter project (w3m can't render js)
  - Run dc list stats

---

  ```text
  C:\SlideWSL>getslidewsl dave mypassword
  user: dave
  uid : 1000
  gid : 1000
  OracleLinux_8_7 already exists. do you wish to delete it?
  Enter Y or N: [Y,N]?Y
  
  <snip>
  
  ----------------------------------------------------------
  
  Done!
  
  Start: 12:38:16.69
  End  : 12:41:43.60
  
  Now run  Windows Remote Desktop  (mstsc.exe)
  Use the computer location: localhost:3390
  Username: dave (and the password you provided)
  
  Or, for a terminal: wsl or oraclelinux87
  Or, for ssh: ssh dave@localhost -p 2223
  
  To launch the devcontainer: dc help
  
  ----------------------------------------------------------
  
  C:\SlideWSL>wsl
  
  [dave@wsl ~]$ dc help
  | Usage: dc [status|reset [cache]|list [stats]|recreate|help]
  | (If found, /home/dave/docker/sync.sh will run first.)
  | When no argument is provided:
  |   -Run or reattach to the devcontainer
  | Optional arguments:
  |   status: Report if the devcontainer is running
  |   reset: Purge all containers, images, and optional build cache
  |   list [stats]: List all containers, images, and optional stats
  |   recreate: Rebuild the devcontainer image and container
  |   help: Show this usage info
  
  [dave@wsl ~]$ dc
  ✔ Container devcontainer Started
  
  ----------------------------
  Welcome to the devcontainer!
  ----------------------------
  
  [dev@devcontainer ~]$ docker compose --profile web up -d
  ✔ Container nginx Started
  [dev@devcontainer ~]$ exit
  
  [dave@wsl ~]$ sudo dnf install -yq w3m
  
  Installed:
  w3m-0.5.3-60.git20230121.el8.x86_64
  
  [dave@wsl ~]$ w3m -dump http://localhost:8000/
  Welcome to nginx!
  
  If you see this page, the nginx web server is successfully installed and
  working. Further configuration is required.
  
  For online documentation and support please refer to nginx.org.
  Commercial support is available at nginx.com.
  
  Thank you for using nginx.
  
  [dave@wsl ~]$ dc
  ✔ Container devcontainer Running
  
  ----------------------------
  Welcome to the devcontainer!
  ----------------------------
  
  [dev@devcontainer ~]$ APPS="starter" docker compose up --force-recreate --build angular_devserver -d
  ✔ Container angular_devserver Started
  
  [dev@devcontainer ~]$ docker compose logs angular_devserver -f
  angular_devserver  | fixuid: fixuid should only ever be used on development systems. DO NOT USE IN PRODUCTION
  angular_devserver  | fixuid: runtime UID '1000' already matches container user 'node' UID
  angular_devserver  | fixuid: runtime GID '1000' already matches container group 'node' GID
  angular_devserver  | ----------> checking /app/angular... fixing!
  angular_devserver  | ----------> creating demo project: angular
  angular_devserver  | CREATE README.md (1061 bytes)
  angular_devserver  | CREATE .editorconfig (274 bytes)
  angular_devserver  | <snip>
  angular_devserver  | - Installing packages (yarn)...
  angular_devserver  | ✔ Packages installed successfully.
  angular_devserver  | ----------> generating application: starter
  angular_devserver  | yarn run v1.22.19
  angular_devserver  | $ ng generate application starter --routing=true --style=scss
  angular_devserver  | CREATE projects/starter/tsconfig.app.json (271 bytes)
  angular_devserver  | CREATE projects/starter/tsconfig.spec.json (281 bytes)
  angular_devserver  | <snip>
  angular_devserver  | UPDATE angular.json (3127 bytes)
  angular_devserver  | UPDATE package.json (1039 bytes)
  angular_devserver  | - Installing packages (yarn)...
  angular_devserver  | ✔ Packages installed successfully.
  angular_devserver  | Done in 24.35s.
  angular_devserver  | ----------> done! back to it...
  angular_devserver  | yarn install v1.22.19
  angular_devserver  | [1/4] Resolving packages...
  angular_devserver  | success Already up-to-date.
  angular_devserver  | Done in 0.45s.
  angular_devserver  | starting webpack dev server(s) for: starter
  angular_devserver  | running ng serve starter --port 4205 --host=0.0.0.0
  angular_devserver  | (if starter doesn't exist, you might see the error: Unknown arguments)
  angular_devserver  | done
  ^C
  
  [dev@devcontainer ~]$ exit
  
  [dave@wsl ~]$ w3m -dump_source http://localhost:4205/
  <!doctype html>
  <html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Starter</title>
    <base href="/">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="icon" type="image/x-icon" href="favicon.ico">
  <link rel="stylesheet" href="styles.css"></head>
  <body>
    <app-root></app-root>
  <script src="runtime.js" type="module"></script><script src="polyfills.js" type="module"></script><script src="styles.js" defer></script>
    <script src="vendor.js" type="module"></script><script src="main.js" type="module"></script></body>
  </html>
  
  [dave@wsl ~]$ dc list stats
  
  images
  REPOSITORY                      TAG       IMAGE ID       CREATED          SIZE
  slidewsl-angular_devserver      latest    cc6022e7cd34   7 minutes ago    995MB
  slidewsl-angular_app_build      latest    2f71e715053c   8 minutes ago    995MB
  slidewsl-angular_node_modules   latest    0c72cfb54798   8 minutes ago    995MB
  slidewsl-devcontainer           latest    e7bb5dbda175   10 minutes ago   563MB
  alpine/socat                    latest    d38d2ef29645   3 days ago       8.64MB
  nginx                           latest    e4720093a3c1   2 weeks ago      187MB
  
  containers
  CONTAINER ID   IMAGE                        COMMAND                  CREATED          STATUS          PORTS                                   NAMES
  419c303df13f   slidewsl-angular_devserver   "/bin/bash -c 'fixui…"   7 minutes ago    Up 7 minutes    0.0.0.0:4200-4210->4200-4210/tcp        angular_devserver
  10df68492303   nginx                        "/docker-entrypoint.…"   8 minutes ago    Up 8 minutes    0.0.0.0:8000->80/tcp, :::8000->80/tcp   nginx
  cef24ed588e4   slidewsl-devcontainer        "/bin/bash -c 'sleep…"   10 minutes ago   Up 10 minutes                                           devcontainer
  f522289d81fa   alpine/socat                 "socat tcp-listen:40…"   11 minutes ago   Up 11 minutes   127.0.0.1:2376->4000/tcp                socat
  
  stats
  CONTAINER ID   NAME                CPU %     MEM USAGE / LIMIT     MEM %     NET I/O           BLOCK I/O   PIDS
  419c303df13f   angular_devserver   0.04%     792.9MiB / 15.56GiB   4.98%     163MB / 4.11MB    0B / 0B     16
  10df68492303   nginx               0.00%     7.152MiB / 15.56GiB   0.04%     2.25kB / 1.34kB   0B / 0B     9
  cef24ed588e4   devcontainer        0.00%     592KiB / 15.56GiB     0.00%     0B / 0B           0B / 0B     1
  f522289d81fa   socat               0.00%     884KiB / 15.56GiB     0.01%     299kB / 671kB     0B / 0B     1
  
  [dave@wsl ~]$
  ```
