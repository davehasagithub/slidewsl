Many of the items below are expanded on in [NOTES](./NOTES.md).

---

**03/14/2024**

- Add keydb cluster

**03/10/2024**

- Add nginx and php-fpm containers
  - Support webpack dev server and dist folder mappings
  - Add script for composer install
  - Add script for creating laravel starter apps
- Refactor wsl distro
  - Move docker folder from `~` to `/`
  - Remove uid/gid handling from batch script
- Refactor angular container
  - Move dev server configs to key/value .conf file
  - Extract a script for creating angular starter apps
  - Support arbitrary arguments to ng build
- Refactor devcontainer
  - Reduce needed env vars
  - Add `dchelp` to reshow motd
  - Install [daveml](https://github.com/davehasagithub/daveml/) for motd

**03/03/2024**

- Add Angular support to the devcontainer
- Improve `devcontainer-launcher.sh` so that `reset` (or `reset cache`) now purges all containers, images,
and build cache; `list` (or `list stats`) shows all containers, images, and resource usage
stats; and `sync.sh` was fixed to recognize the need to restart if
the sync script itself was updated. Also, `sync.sh` now runs first
before all actions.
- Fix `ctrl-p` conflict in the devcontainer between Docker `detachKeys`
sequence and the shortcut for bash command history
- Mount timezone files to the devcontainer
- `getslidewsl.bat` now supports passing the location of sync.sh so that
it can be moved into position for the initial creation of the devcontainer.

**02/25/2024**
- The build technique now supports embedding multiple assets into
the batch file. It works very similar to before, except now it
embeds the base64 encoded chunks resulting from tarring and
zipping the entire assets/ folder. These files are available for use
during provisioning, so, incredibly, the shell script no longer resorts to
creating files with echo and heredoc.
- SlideWSL now includes a devcontainer. Shout out to [@jblotus](https://github.com/jblotus)
for teaching me about Docker-from-Docker!
- Remove NodeJS and Yarn from the WSL2 distro

**02/20/2024 [Initial release]**

- Builds a WSL2 distro running XFCE
- Accessible over RDP or SSH
- Bundled with:
  - Git, Docker (daemon and CLI), ~~NodeJS 14.20.1~~, ~~Yarn 1.22.19~~, Firefox, Chromium,
    and JetBrains Toolbox (with a Desktop shortcut)
  - `/usr/local/bin/add-host.sh`: This can be used to add persistent entries to the WSL2 hosts file.
  - `/etc/profile.d/wsl-keepalive.sh`: Used to keep the WSL2 instance from [going idle](https://github.com/microsoft/WSL/issues/8654#issuecomment-1195973431) and terminating.
- Build technique: `build.sh` generates `dist/getslidewsl.bat` by embedding
`slidewsl.sh` into base64 chunks that become a series of variables in the
batch file. These are then decoded to reconstitute the script for
provisioning the distro.
