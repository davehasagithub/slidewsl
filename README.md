# SlideWSL

The `S`imple `L`inux `I`nterface for `DE`veloping on `WSL` (Slide Whistle!)

SlideWSL is a tool to easily create a custom Linux development environment
on Windows using just a **single DOS batch file**. It runs from CMD with
no user interaction [^1].

[^1]: Except a confirmation to overwrite an existing distro, or a Windows UAC popup for a WSL update.

Simple shell scripts and various assets are encoded into base64 chunks that
become a series of variables in the lone batch file. These can then be decoded
to reconstitute everything needed to provision the WSL2 distro.

The particular dev environment included here is an opinionated set of Docker
containers for nginx, Angular, PHP/Laravel, KeyDB, MySQL, and phpMyAdmin.
However, a similar approach could be reapplied for other tech stacks.

See [NOTES](./NOTES.md) for details,
and [CHANGELOG](./CHANGELOG.md) for background.

## Warning

This is experimental. **Use at your own risk!**

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
getslidewsl.bat <username> <password> [<path to sync.sh>]
```
