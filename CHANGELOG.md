**2/25/2024**
- The build technique now supports embedding multiple assets into
the batch file. It works very similar to before, except now it
embeds the base64 encoded chunks resulting from tarring and
zipping the entire assets/ folder. These files are available for use
during provisioning, so, incredibly, the shell script no longer resorts to
creating files with echo and heredoc.
- SlideWSL now includes a devcontainer.
  - For more, see [README](./README.md) and [NOTES](./NOTES.md).
  - Shout out to [@jblotus](https://github.com/jblotus)
for teaching me about Docker-from-Docker!
- NodeJS and Yarn are no longer installed in the WSL2 distro.

**2/20/2024 [Initial release]**

- Builds a WSL2 distro running XFCE
- Accessible over RDP or SSH
- Bundled with:
  - Git
  - Docker (daemon and CLI)
  - ~~NodeJS 14.20.1~~
  - ~~Yarn 1.22.19~~
  - Firefox
  - Chromium
  - JetBrains Toolbox (with Desktop shortcut)
- Includes:
  - `/usr/local/bin/add-host.sh`
    - This can be used to add persistent entries to the hosts file.
    - Real life example: This could add _wsl_ subdomains so that a JavaScript app
      can reach services in another location (maybe even a VirtualBox VM?).
      Then, Angular could use proxy.wsl.conf.json with a wsl subdomain target.
  - `/etc/profile.d/wsl-keepalive.sh`
- Build technique: `build.sh` generates `dist/getslidewsl.bat` by embedding
`slidewsl.sh` into base64 chunks that become a series of variables in the
batch file. These are then decoded to reconstitute the script for
provisioning the distro.
