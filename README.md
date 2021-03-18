# Ubuntu build

This project is used to build Ubuntu 20.04 (focal) for Conclusive Engineering development boards.

# Prerequisites

Install following packages before continuing with build process.

```shell
sudo apt install debootstrap util-linux make git binutils-arm-linux-gnueaeabihf gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf gcc-aarch64-linux-gnu g++-aarch64-linux-gnu binutils-aarch64-linux-gnu bison flex gcc-riscv64-linux-gnu libyaml-cpp-dev libyaml-dev libelf-dev qemu-user-static 
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
### Board specific prerequisites
Install following packages before continuing with build process.

```shell
sudo apt install gcc-riscv64-linux-gnu
```

### Build procedure
1. Prepare eMMC image:

    `make image PROFILE=rchd-pf`

### Flash procedure

1. Reset the RCHD-PF board.

2. Stop at HSS by pressing <space> within the timeout

3. Connect USB host to the board (micro-B OTB)

4. Enter Mass Storage mode by issueing HSS command:

    `usbdmsc`

5. Determine path of the new disk (</dev/sdx>)

6. Run:

	`sudo make flash PROFILE=rchd-pf TARGET_PATH=</dev/sdx>`

