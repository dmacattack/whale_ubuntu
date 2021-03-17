# Ubuntu build

This project is used to build Ubuntu 20.04 (focal) for Conclusive Engineering development boards.

# Prerequisites

Install following packages before continuing with build process.

```shell
sudo apt install debootstrap util-linux make git binutils-arm-linux-gnueaeabihf gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf gcc-aarch64-linux-gnu g++-aarch64-linux-gnu binutils-aarch64-linux-gnu
```

Initialize submodules containing external projects:

```shell
git submodule update --init --recursive
```

# Board specific instructions

## KSTR-SAMA5D27
### Build procedure

1. Prepare directories for building the software package:

    `make dirs PROFILE=kstr-sama5d27`

2. Build bootloaders for the CPU - AT91Bootstrap and U-Boot:

    `make bootloader PROFILE=kstr-sama5d27`

3. Build root filesystem:

    `sudo make rootfs PROFILE=kstr-sama5d27`

4. Prepare SD card image:

    `sudo make image PROFILE=kstr-sama5d27`

## WHLE-LS1046a

...

##  RCHD-PF

...
