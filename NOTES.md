### Miscellaneous

- The output from WSL2 provisioning can be viewed with `sudo less /root/provision.log`.


- The installation process creates a sparse virtual hard disk image (using qemu-img
  in the qcow2 format).
  It's intended to be used for project and local database files.
  The disk image can be disconnected in order to rebuild the underlying
  WSL2 host; it can then be seamlessly reattached without loss of data
  or configuration (such as local changes, branches, and shelved items).
  - The image file is created at `%userprofile%\slidewsl_ubuntu.img`
    and mounted at `/mnt/slidewsl`.
    It's set to grow to a max size of 20G (currently hard-coded in `disk-image.sh`).
  - The mount is controlled by the `disk-image` systemd service.
  - To unmount for backup or rebuild:
    - Use `sudo systemctl stop disk-image`, then `exit`, and `wsl --shutdown`.
    - Be sure to stop other tools that might try to write to this mount folder.
  - It's unclear if systemd shuts down gracefully when Windows shuts down or reboots:
    [8939](https://github.com/microsoft/WSL/discussions/11225),
    [11225](https://github.com/microsoft/WSL/issues/8939).
  - <details>
      <summary>To increase the size of an existing disk image</summary>
    
      ```bash
      # Shut everything down
      source /etc/disk-image.conf
      echo image: $IMG_LOCATION
      docker compose --profile "*" down -v
      df -h /mnt/slidewsl | grep /dev/nbd0
      sudo systemctl stop disk-image
      sudo qemu-img info $IMG_LOCATION
      # Back up the image file now before continuing
      # Resize the image file
      sudo qemu-img resize $IMG_LOCATION +10G # specify increase
      sudo qemu-nbd --connect=/dev/nbd0 "$IMG_LOCATION"
      sudo e2fsck -f /dev/nbd0
      sudo resize2fs /dev/nbd0
      sudo e2fsck -f /dev/nbd0
      lsblk -l /dev/nbd0
      sudo qemu-nbd --disconnect /dev/nbd0
      sudo qemu-img info $IMG_LOCATION
      sudo systemctl start disk-image
      df -h /mnt/slidewsl
      ```
    </details>

  
- To compact the virtual disk used by WSL2 itself, shut everything down, then find your VHD, for example:

  `C:\Users\<YourUsername>\AppData\Local\Packages\<DistroPackage>\LocalState\ext4.vhdx`

  (For Ubuntu 22, the distro package name will include CanonicalGroupLimited.Ubuntu22.04LTS_*.)

  Now use diskpart (at your own risk!):

  ```dosbatch
  diskpart
  select vdisk file="<path_to>\ext4.vhdx"
  attach vdisk readonly
  compact vdisk
  detach vdisk
  exit
  ```


- You could [export](https://learn.microsoft.com/en-us/windows/wsl/basic-commands#export-a-distribution) and import your WSL2 distro for repeat installs or to move to a different drive:

  ```dosbatch
  set wsl_path=%userprofile%\Desktop\wsl
  set origin_distro=Ubuntu-22.04
  set second_distro=Ubuntu-22.04_Legacy
  mkdir %wsl_path% 2>nul
  cd %wsl_path%
  mkdir images 2>nul
  mkdir instances 2>nul
  wsl --export %origin_distro% images\slidewsl_wsl_distro.tar
  wsl --import %second_distro% instances\%second_distro% images\slidewsl_wsl_distro.tar
  echo now run: wsl -d %second_distro%
  ```
