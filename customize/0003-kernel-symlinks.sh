#!/bin/sh

KERNEL_VERSION=$(${CHROOT_CMD} dpkg-query \
    --showformat='${Version}' \
    --show linux-image-${KERNEL_VARIANT})

ln -sf \
    /usr/lib/linux-image-${KERNEL_VERSION}/${DEVICETREE_NAME} \
    ${ROOTDIR}/boot/board.dtb

${CHROOT_CMD} linux-update-symlinks install \
    ${KERNEL_VERSION} \
    /boot/vmlinuz-${KERNEL_VERSION}
