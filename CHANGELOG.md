
---

**04/07/2024**

- Enable WSL interop [^1]

[^1]: With Intellij launched from Windows using Git over WSL, an
interactive rebase tries to run `jbr/bin/java.exe` via `mnt/c`
for a Java class called `git4idea.editor.GitRebaseEditorApp`.
Without interop, the error looks like:
`UtilAcceptVsock:250: accept4 failed 110 There was a problem with the editor`.
Related: [8677](https://github.com/microsoft/WSL/issues/8677).

**04/06/2024**

- Make exposed ports configurable

**04/02/2024**

- Move php and angular version info to env

**03/28/2024**

- Add sample sync script, fix password issue, use snake_case variable names

**03/27/2024**

- Rename repo files for clarity, remove add-host.sh

**03/25/2024**

- Add virtual disk image support
- Move `/docker` under $HOME as `~/slidewsl`

**03/22/2024**

- Remove the _devcontainer_ container and socat
- Change `devcontainer-launcher.sh` to `dev-admin.sh`

**03/18/2024**

- Generate self-signed cert in nginx container
- Add php-cs-fixer, phpstan, psalm to php container

**03/16/2024**

- Add mysql and phpmyadmin containers

**03/14/2024**

- Add containers for keydb cluster

**03/10/2024**

- Add nginx and php-fpm containers
- Support composer installs and webpack dev server
- Add scripts to create starter laravel and angular apps
- Reduce needed env vars
- Include [daveml](https://github.com/davehasagithub/daveml/)

**03/03/2024**

- Add angular container
- Add `reset` and `list` to `devcontainer-launcher.sh`
- Restart `sync.sh` if script itself was updated
- Fix `ctrl-p` conflict between Docker `detachKeys` sequence and bash command history shortcut
- Mount timezone files
- Support `sync.sh` path as argument to `getslidewsl.bat`

**02/25/2024**
- Support embedding multiple assets into `getslidewsl.bat`
- Add a devcontainer container
- Remove NodeJS and Yarn

**02/20/2024 [Initial release]**

- Build a WSL2 distro running XFCE accessible over RDP or SSH
- Bundle with Git, Docker, ~~NodeJS 14.20.1~~, ~~Yarn 1.22.19~~, Firefox, Chromium, JetBrains Toolbox
- Support embedding `slidewsl.sh` inside `dist/getslidewsl.bat`
