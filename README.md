# SlideWSL

The `S`imple `L`inux `I`nterface for `DE`veloping on `WSL` (Slide Whistle!)

With SlideWSL, you can quickly create a custom Oracle Linux environment
on Windows using just a **single DOS batch file** that runs from CMD with
no user interaction [^1].

[^1]: Except a Y/N confirmation if an existing distro will be overwritten.

## Details

- Companion assets necessary for provisioning are encoded and embedded into
the lone .bat file in order to achieve maximum portability.

- This distro includes an optional graphical environment:

  - A lightweight XFCE desktop is accessible by connecting to _localhost_ from
a remote desktop client such as Microsoft Remote Desktop or FreeRDP. You won't
need an X11 server (such as VcXsrv or Xming) running on the Windows host.
  - This comes with JetBrains Toolbox, plus Firefox and Chromium.

- This also incorporates a Docker _devcontainer_.
We want to keep the WSL2 distro light. If we're developers, we also want a
consistent and reproducible environment for all of our tools and dependencies.
To achieve these goals:

  - SlideWSL installs Docker on the WSL2 host, along with a
Docker Compose configuration file, a convenient admin script, and Git.
  - The script will
use Compose to launch the devcontainer.
  - The service entry for the devcontainer in
the Compose configuration will grant it read-only access to the identical
Compose configuration through a bind mount. This allows it to
orchestrate all other containers required for our development projects.
  - Inside the devcontainer, the Docker CLI communicates with the daemon running
in the WSL2 distro. This works by connecting over a port managed by _socat_ that
relays into the privileged Docker socket.


See [NOTES](./NOTES.md) for other related info,
and [CHANGELOG](./CHANGELOG.md) for background and the latest updates.

## Warning

This is still experimental. **Use at your own risk!**

## Install

To quickly download the latest .bat file, you can run this from CMD:

```dosbatch
powershell iwr -uri "https://raw.githubusercontent.com/davehasagithub/slidewsl/master/dist/getslidewsl.bat" -outfile getslidewsl.bat
```

## Requirements

- First, be sure to familiarize yourself with WSL2
- See: https://learn.microsoft.com/en-us/windows/wsl/install-manual
- Enable Windows feature: _Windows Subsystem for Linux_
- And the feature: _Virtual Machine Platform_
- Update Subsystem for Linux: https://apps.microsoft.com/detail/9P9TQF7MRM4R
- Install Oracle Linux 8.7: https://apps.microsoft.com/detail/9NGGZVB0BKD9

## Usage

```dosbatch
C:\slidewsl>getslidewsl
Usage: getslidewsl.bat <username> <password> [<uid> <gid>]
uid is optional. gid is required with uid.
uid and gid default to 1000 and must be 1000 or greater.
```
