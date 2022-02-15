#!/bin/sh

mkdir -p ${ROOTDIR}/boot/extlinux
sed \
    -e "s|@UBUNTU_VERSION@|${UBUNTU_VERSION}|g" \
    -e "s|@KERNEL_BOOTARGS@|${KERNEL_BOOTARGS}|g" \
    ${SRCROOT}/etc/extlinux.conf.in > ${ROOTDIR}/boot/extlinux/extlinux.conf
