<img alt="screenshot" src="./slidewsl.png" width="500" height="281" />

# slidewsl

The `S`imple `L`inux `I`nterface for `DE`veloping on `WSL`

This single batch file, [getslidewsl.bat](dist/getslidewsl.bat), will build a
graphical Linux environment on Windows. It is accessible by connecting to _localhost_
using a remote desktop client such as Microsoft Remote Desktop or FreeRDP. This
requires WSL2 and uses the Oracle Linux 8.7 distribution with the lightweight XFCE
desktop. This doesn't require an X11 server, such as VcXsrv or Xming, to be running
on the Windows host.

To quickly download the latest, you can run this from CMD:

`powershell iwr -uri "https://raw.githubusercontent.com/davehasagithub/slidewsl/master/dist/getslidewsl.bat" -outfile getslidewsl.bat`

**Very preliminary. Use at your own risk! Note that this script will run wsl --shutdown.**

## Usage

`  c:\dev> getslidewsl username password  `

## Details

Consider this a template that can be adjusted for your needs. It's currently
bundled with Docker, NodeJS 14.20.1, Yarn 1.22.19, Firefox, Chromium, and
JetBrains Toolbox. It runs in under 5 minutes on my machine.

The build script, [build.sh](./build.sh), uses _base64_ to encode a provisioning
shell script into chunks that get embedded as variables in the batch file (using
a simple placeholder replacement). This was done to increase portability of the
batch file by not requiring a second file dependency or ugly escaping mechanisms.
Basically, it seemed like a clever idea that was fun to implement!

Because this approach could be used to hide nefarious code, I suggest inspecting
the source and building yourself. I do this using a separate wsl ubuntu distro:

`wsl -d ubuntu /mnt/c/path/slidewsl/build.sh`

The slidewsl distro adds `/usr/local/bin/update-hosts.sh <hostname> <ip>`. It can
be used to add persistent entries to the hosts file that include a _wsl_ subdomain.
I'm currently using this to allow javascript code to reach out to services in an
older VirtualBox VM. For me, this works by creating a new proxy.wsl.conf.json file
for Angular, with the target set to the wsl subdomain; the `--proxy-config` option
is used to launch the dev server.

To enable LAN access, create a port forward for Windows and adjust firewalls as needed. For example:

```shell
wsl -e sh -c "ip route show | grep -i default | awk '{ print $3}'"
netsh interface portproxy add v4tov4 listenport=3390 listenaddress=0.0.0.0 connectport=3390 connectaddress=<ip>
netsh interface portproxy show all
netsh interface portproxy delete v4tov4 listenport=3390 listenaddress=0.0.0.0
```

Once up and running, you'll probably do things like:

```
export SOME_ENV_VAR=value
git login # or:
# cp /mnt/c/Users/<name>/.ssh/id_* /mnt/c/Users/<name>/.ssh/config ~/.ssh
# chmod 600 ~/.ssh/config ~/.ssh/id_*
git clone git@example.com:path/project.git ~/src/project
yarn --cwd ~/src/project/ install --frozen-lockfile
# import intellij configs, maybe copy .idea/modules.xml, etc
```

Happy coding!
