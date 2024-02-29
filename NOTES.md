# Notes

<img alt="screenshot" src="./slidewsl.png" width="500" height="281" />

### Miscellaneous

- The output from WSL2 provisioning can be viewed with `sudo less /root/provision.log`.

- User and group identifiers:

  `getslidewsl.bat` allows you to specify the uid/gid for the WSL distro (the defaults are 1000/1000).
  The same uid/gid will be used when creating the non-root user in the devcontainer.

  (As of this writing, the username in the devcontainer is hard-coded as `dev` in compose.yaml.
This could easily be parameterized or set to match the WSL2 user.)

  ```dosbatch
  C:\slidewsl>getslidewsl
  Usage: getslidewsl.bat <username> <password> [<uid> <gid>]
  uid is optional. gid is required with uid.
  uid and gid default to 1000 and must be 1000 or greater.
  ```

  ```bash
  [dave@wsl ~]$ id
  uid=7777(dave) gid=8888(dave) groups=8888(dave),994(docker)
  [dave@wsl ~]$ dc
  [dev@devcontainer ~]$ id
  uid=7777(dev) gid=8888(dev) groups=8888(dev)

  ```

- What is sync.sh?

  - This is optional and may be removed.
  - The thinking is that, when launching the devcontainer, it could be handy for prep work, such as running rsync, dos2unix, etc.
    - Before launching the devcontainer, `run.sh` checks to see if a script called `sync.sh` exists in the same folder as itself.
      If so, it runs it. On return, if `run.sh` finds that its own timestamp has changed, it restarts itself.

### More

- Consider [exporting](https://learn.microsoft.com/en-us/windows/wsl/basic-commands#export-a-distribution) your WSL distro for repeat installs.

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

- This is a basic walkthrough of the current state:
  - Install SlideWSL
  - Launch the devcontainer
  - Start the web server
  - Exit back to WSL
  - Install a text-based browser
  - Visit the nginx welcome page
- Notice that dc (for devcontainer) is a shell function to call ~/docker/run.sh.

  ```text
  C:\SlideWSL>getslidewsl dave mypassword 5500 6600
  user: dave
  uid : 5500
  gid : 6600
  OracleLinux_8_7 already exists. do you wish to delete it?
  Enter Y or N: [Y,N]?Y
  <snip...>

  ----------------------------------------------------------
  
  Done!
  
  Start: 20:00:22.86
  End  : 20:04:55.29
  
  Now run  Windows Remote Desktop  (mstsc.exe)
  Use the computer location: localhost:3390
  Username: dave (and the password you provided)
  
  Or, for a terminal: wsl or oraclelinux87
  Or, for ssh: ssh dave@localhost -p 2223
  
  To launch the devcontainer: dc help
  
  ----------------------------------------------------------
  
  C:\SlideWSL>wsl
  [dave@wsl ~]$

  [dave@wsl ~]$ which dc
  dc ()
  {
      ( export ALIAS_USED=dc;
      ~/docker/run.sh "$@" )
  }

  [dave@wsl ~]$ dc help
  | Usage: dc [status|clean|recreate|help]
  | When no argument is provided:
  |   -Run or reattach to the devcontainer
  |    (If found, /home/dave/docker/sync.sh will run first.)
  | Optional arguments:
  |   status: Check if the devcontainer is running
  |   clean: Purge related containers and images
  |   recreate: Force rebuild of the devcontainer
  |   help: Show this usage info
  
  [dave@wsl ~]$ dc status
  The devcontainer is not running

  [dave@wsl ~]$ dc
  The devcontainer is not running
  Running sync.sh
  Script was not updated. Continuing
  Launching socat
  ✔ Container devcontainer Started
  
  ----------------------------
  Welcome to the devcontainer!
  ----------------------------
  
  To start the webapp:
  docker compose --profile web up -d
  
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
  
  [dave@wsl ~]$
  ```
