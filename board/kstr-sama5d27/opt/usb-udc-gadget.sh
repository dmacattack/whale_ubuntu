#!/bin/sh

# 'libcomposite' kernel module must be loaded before starting this script

# Prepare usb gadget
cd /sys/kernel/config/usb_gadget/
mkdir -p usb-gadgets
cd usb-gadgets

# Initial setup of the gadget
echo 0x1d6b > idVendor # Linux Foundation
echo 0x0104 > idProduct # Multifunction Composite Gadget
echo 0x0100 > bcdDevice # v1.0.0
echo 0x0200 > bcdUSB # USB2
mkdir -p strings/0x409
echo "0123456789abcdef" > strings/0x409/serialnumber
echo "KSTR-SAMA5D27 USB Gadget" > strings/0x409/manufacturer
echo "KSTR-SAMA5D27 Gadget" > strings/0x409/product
mkdir -p configs/c.1/strings/0x409
echo "Config 1: ECM network" > configs/c.1/strings/0x409/configuration
echo 250 > configs/c.1/MaxPower

# Create Ethernet gadget
mkdir -p functions/ecm.usb0
echo "32:70:05:18:ff:7a" > functions/ecm.usb0/host_addr
echo "32:70:05:18:ff:7b" > functions/ecm.usb0/dev_addr
ln -s functions/ecm.usb0 configs/c.1/

# Create ACM (serial) gadget
mkdir -p functions/acm.GS0
ln -s functions/acm.GS0 configs/c.1

# Initalize the gadget
ls /sys/class/udc > UDC
