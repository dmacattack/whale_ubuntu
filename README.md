# Ubuntu build

This project is used to build Ubuntu 20.04 (focal) for Conclusive Engineering development boards.

## Prerequisites

Install following packages before continuing with build process.

```shell
sudo apt install debootstrap util-linux make git binutils-arm-linux-gnueabihf gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf gcc-aarch64-linux-gnu g++-aarch64-linux-gnu binutils-aarch64-linux-gnu bison flex gcc-riscv64-linux-gnu libyaml-cpp-dev libyaml-dev libelf-dev qemu-user-static
```

Initialize submodules containing external projects:

```shell
git submodule update --init --recursive
```

## Board specific instructions

## KSTR-SAMA5D27

### Build procedure

1. Prepare SD card image:

```shell
sudo make image PROFILE=kstr-sama5d27
```

### Flash procedure

1. Run:

```shell
sudo make flash PROFILE=kstr-sama5d27 TARGET_PATH=</dev/sdX>
```

## WHLE-LS1xxA

### Build procedure

1. Prepare eMMC image:

```shell
sudo make image PROFILE=whle-ls1046a # WHLE-LS1026A and WHLE-LS1046A or
sudo make image PROFILE=whle-ls1088a # WHLE-LS1048A and WHLE-LS1088A
```

### Flash procedure

Flashing can be performed from the U-Boot prompt via TFTP.

1. Configure the network in the U-Boot

```shell
=> setenv ipaddr x.x.x.x
=> setenv serverip x.x.x.y
```

Alternatively, use the `dhcp` command to configure network using DHCP.

2. Download the image to the eMMC memory:

```shell
=> tftpclone mmc 0 0 ubuntu-jammy-whle-ls1088a-2023-11-11-ebbad53.img
```

## RCHD-PF

### Board specific prerequisites

Install following packages before continuing with build process.

```shell
sudo apt install gcc-riscv64-linux-gnu
```

### Build procedure

1. Prepare eMMC image:

```shell
sudo make image PROFILE=rchd-pf`
```

### Flash procedure

1. Reset the RCHD-PF board.

2. Stop at HSS by pressing <space> within the timeout

3. Connect USB host to the board (micro-B OTB)

4. Enter Mass Storage mode by issueing HSS command:

    `usbdmsc`

5. Determine path of the new disk (</dev/sdX>)

6. Run:

    `sudo make flash PROFILE=rchd-pf TARGET_PATH=</dev/sdX>`
