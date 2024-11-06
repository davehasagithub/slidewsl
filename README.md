# SlideWSL

The `S`imple `L`inux `I`nterface for `DE`veloping on `WSL` (Slide Whistle!)

SlideWSL allows you to set up a WSL2 environment using a
**single DOS batch file** that runs from CMD without user interaction.

This works because simple shell scripts and various assets are encoded into base64
chunks that become a series of variables in the lone batch file. These can then be
decoded to reconstitute everything needed to provision the WSL2 distro.
(Interaction may be required to confirm overwriting an existing distro and for
Windows UAC popups.)

A sparse virtual hard **disk image** is mounted into the instance (using qemu-img
in the qcow2 format); this can be disconnected, backed up, the WSL2 instance
rebuilt, and then reattached without loss of project files.

Also see [NOTES](./NOTES.md) and [CHANGELOG](./CHANGELOG.md).

## Warning

This is experimental. Use at your own risk.

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
- Install Ubuntu 22.04: https://apps.microsoft.com/detail/9pn20msr04dw

## Usage

```dosbatch
getslidewsl.bat <username> <password>
```
