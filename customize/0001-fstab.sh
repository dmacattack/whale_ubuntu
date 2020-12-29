#!/bin/sh

truncate -s 2G ${SRCROOT}/swapfile
sed \
    -e "s|@ROOTFS_UUID@|${ROOTFS_UUID}|g" \
    ${SRCROOT}/etc/fstab.in > ${ROOTDIR}/etc/fstab
