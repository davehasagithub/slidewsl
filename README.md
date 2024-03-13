# SlideWSL

The `S`imple `L`inux `I`nterface for `DE`veloping on `WSL` (Slide Whistle!)

With SlideWSL, you can quickly create a custom Linux development environment
on Windows using just a **single DOS batch file** that runs from CMD with
no user interaction [^1].

[^1]: Except a Y/N confirmation if an existing distro will be overwritten,
or if the WSL update triggers UAC.

The built-in development environment is an opinionated set of containers for
Angular, Laravel, and nginx. While it does allow for some customization, it
could also serve as a foundation for creating something tailored to your needs.

- Uses Oracle Linux 8.
- Companion assets embedded into a lone .bat file.
- Includes an optional graphical environment.
- Incorporates a Docker _devcontainer_.

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
