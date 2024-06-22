
---

**06/22/2024**

- Use a shared template to create service entries in the Compose YAML.
  This moves tons of conditionals out of individual services,
  and sets things up for further cleanup.

**06/16/2024**

- Generate Compose YAML files from Go Templates
- Install golang, jq, local-registry-list.sh script
- Collapse env files, stop using env_file attribute
- Add staging container, support for stack deploy
- Enable sparseVhd in WSL2 instance
- Support Angular SSR

**03/27/2024 - 04/07/2024**

- Enable WSL interop [^1]
- Use vars for exposed ports, php, angular version numbers
- Add sample sync.sh script and sample custom env file

[^1]: With IntelliJ launched from Windows using Git over WSL, an
interactive rebase tries to run `jbr/bin/java.exe` via `mnt/c`
for a Java class called `git4idea.editor.GitRebaseEditorApp`.
Without interop, the error looks like:
`UtilAcceptVsock:250: accept4 failed 110 There was a problem with the editor`.
Related: [8677](https://github.com/microsoft/WSL/issues/8677).

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
