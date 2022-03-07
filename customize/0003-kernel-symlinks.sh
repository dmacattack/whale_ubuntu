#!/bin/sh

KERNEL_VERSION=$(${CHROOT_CMD} dpkg-query \
    --showformat='${Depends}' \
    --show linux-image-${KERNEL_VARIANT} | cut -d, -f1 | cut -d- -f3-)

ln -sf \
    /usr/lib/linux-image-${KERNEL_VERSION}/${DEVICETREE_NAME} \
    ${ROOTDIR}/boot/board.dtb

${CHROOT_CMD} linux-update-symlinks install \
    ${KERNEL_VERSION} \
    /boot/vmlinuz-${KERNEL_VERSION}
