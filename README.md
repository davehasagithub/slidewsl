# SlideWSL

The `S`imple `L`inux `I`nterface for `DE`veloping on `WSL` (Slide Whistle!)

With SlideWSL, you can quickly create a custom Oracle Linux environment
on Windows using just a **single DOS batch file** that runs from CMD with
no user interaction [^1].

[^1]: Except a Y/N confirmation if an existing distro will be overwritten.

## Details

- Companion assets necessary for provisioning are encoded and embedded into
the lone .bat file in order to achieve maximum portability.
- This distro includes an optional graphical environment.
- This also incorporates a Docker _devcontainer_.

See [NOTES](./NOTES.md) for details,
and [CHANGELOG](./CHANGELOG.md) for background.

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
Usage: getslidewsl.bat <username> <password> [<uid> <gid> [<path to sync.sh>]]
uid is optional. gid is required with uid.
uid and gid default to 1000 and must be 1000 or greater.
```
