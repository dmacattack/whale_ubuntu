#!/bin/sh

# 'libcomposite' kernel module must be loaded before starting this script

# Prepare usb gadget
cd /sys/kernel/config/usb_gadget/
mkdir -p usb-gadgets

gadget_fs="/sys/kernel/config/usb_gadget/usb-gadgets/"

# Initial setup of the gadget
echo "0x0200" > ${gadget_fs}bcdUSB # USB2
echo "2" > ${gadget_fs}bDeviceClass
echo "0x1d6b" > ${gadget_fs}idVendor # Linux Foundation
echo "0x0104" > ${gadget_fs}idProduct # Multifunction Composite Gadget
echo "0x0200" > ${gadget_fs}bcdDevice # v2.0.0

mkdir -p ${gadget_fs}strings/0x409
echo "0123456789abcdef" > ${gadget_fs}strings/0x409/serialnumber

echo "Conclusive Devices" > ${gadget_fs}strings/0x409/manufacturer
echo "KSTR-SAMA5D27" > ${gadget_fs}strings/0x409/product

# Linux configuration (ECM + Serial)

mkdir ${gadget_fs}configs/c.1
echo "0xC0" > ${gadget_fs}configs/c.1/bmAttributes # Self powered
echo "1" > ${gadget_fs}configs/c.1/MaxPower # 2mA
mkdir -p ${gadget_fs}configs/c.1/strings/0x409
echo "ECM+Serial" > ${gadget_fs}configs/c.1/strings/0x409/configuration

# Create Ethernet gadget
mkdir -p ${gadget_fs}functions/ecm.usb0
echo "32:70:05:18:ff:7a" > ${gadget_fs}functions/ecm.usb0/host_addr
echo "32:70:05:18:ff:7b" > ${gadget_fs}functions/ecm.usb0/dev_addr
ln -s ${gadget_fs}functions/ecm.usb0 ${gadget_fs}configs/c.1

# Create ACM (serial) gadget
mkdir -p ${gadget_fs}functions/acm.GS0
ln -s ${gadget_fs}functions/acm.GS0 ${gadget_fs}configs/c.1

# Windows 10 configuration (RNDIS)

mkdir ${gadget_fs}configs/c.2
echo "0xC0" > ${gadget_fs}configs/c.2/bmAttributes # Self powered
echo "1" > ${gadget_fs}configs/c.2/MaxPower # 2mA

mkdir -p ${gadget_fs}configs/c.2/strings/0x409
echo "RNDIS" > ${gadget_fs}configs/c.2/strings/0x409/configuration

# Based on: https://answers.microsoft.com/en-us/windows/forum/all/windows-10-vs-remote-ndis-ethernet-usbgadget-not/cb30520a-753c-4219-b908-ad3d45590447

echo "1" > ${gadget_fs}os_desc/use # Force Windows using OS Descriptors
echo "0xcd" > ${gadget_fs}os_desc/b_vendor_code # Microsoft
echo "MSFT100" > ${gadget_fs}os_desc/qw_sign # Microsoft

mkdir -p ${gadget_fs}functions/rndis.usb0
echo "32:70:05:18:ff:7c" > ${gadget_fs}functions/rndis.usb0/host_addr
echo "32:70:05:18:ff:7d" > ${gadget_fs}functions/rndis.usb0/dev_addr
echo "RNDIS" > ${gadget_fs}functions/rndis.usb0/os_desc/interface.rndis/compatible_id #  Windows RNDIS Drivers
echo "5162001" > ${gadget_fs}functions/rndis.usb0/os_desc/interface.rndis/sub_compatible_id # Windows RNDIS 6.0 Driver
ln -s ${gadget_fs}functions/rndis.usb0 ${gadget_fs}configs/c.2
ln -s ${gadget_fs}configs/c.2 ${gadget_fs}os_desc

# Initalize the gadget
ls /sys/class/udc > ${gadget_fs}UDC

ifconfig usb0 192.168.12.1 netmask 255.255.255.252 || true
udhcpd /etc/udhcpd.usb0.conf
ifconfig usb1 192.168.13.1 netmask 255.255.255.252 || true
udhcpd /etc/udhcpd.usb1.conf
