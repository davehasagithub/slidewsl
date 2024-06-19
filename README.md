# SlideWSL

The `S`imple `L`inux `I`nterface for `DE`veloping on `WSL` (Slide Whistle!)

SlideWSL is a web application platform for Windows featuring a containerized
development environment with support for Docker Swarm deployment.

The development environment runs on WSL2 and is installed using just a
**single DOS batch file** that runs from CMD without user interaction [^1].

A sparse virtual hard disk image is mounted into the instance (using qemu-img
in the qcow2 format); this can be disconnected, backed up, the WSL2 instance
rebuilt, and then reattached without loss of project files.

A lightweight XFCE desktop is accessible by connecting to _localhost_ from
a remote desktop client.

The particular dev environment included here is an opinionated stack
using nginx, Angular (with server-side rendering support), PHP/Laravel,
KeyDB, MySQL, and phpMyAdmin. Customizations can be easily applied
through a script that syncs the SlideWSL repo and ./local folders
from the host to the WSL2 instance.

Containers are managed by Docker Compose with YAML files that are generated
using Go Templates. These templates are used to create configurations for
both local and Swarm deployable environments.

A lightweight _staging_ container is included with its own Docker Engine.
By place this in Swarm mode, and pulling from a local registry, we can
simulate and test deployments on the developer machine.

In order to give the developer full control, this project aims to
provision the WSL2 distro on-demand and build all images locally.
Because of this, things will be slow until the build cache is produced
and a lot of disk space will be necessary.

SlideWSL is still in an early stage.
There is currently no macOS support, pipeline integrations, or service health checks.
The documentation is lacking and often out-of-date.
And, finally, most commands are still done through direct use of the Docker CLI.




[^1]: This works because simple shell scripts and various assets are encoded into base64
  chunks that become a series of variables in the lone batch file. These can then be
  decoded to reconstitute everything needed to provision the WSL2 distro.
  Interaction may be required to confirm overwriting an existing distro and for Windows UAC popups.
 




See [NOTES](./NOTES.md) for details,
and [CHANGELOG](./CHANGELOG.md) for background.

## Warning

This is experimental. **Use at your own risk!**

## Install

To quickly download the latest batch file, you can run this from CMD:

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
getslidewsl.bat <username> <password> [<path to sync.sh>]
```
