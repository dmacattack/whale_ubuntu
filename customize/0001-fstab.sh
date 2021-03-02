#!/bin/sh

sed \
    -e "s|@ROOTFS_UUID@|${ROOTFS_UUID}|g" \
    ${SRCROOT}/etc/fstab.in > ${ROOTDIR}/etc/fstab
