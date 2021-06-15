#!/bin/sh

mkdir -p ${ROOTDIR}/etc/modules-load.d/
touch ${ROOTDIR}/etc/modules-load.d/libcomposite.conf
/bin/sh -c 'echo "libcomposite"' >> ${ROOTDIR}/etc/modules-load.d/libcomposite.conf

mkdir -p ${ROOTDIR}/etc/systemd/system/
cp ${SRCROOT}/etc/systemd/system/usb-gadget.service ${ROOTDIR}/etc/systemd/system/usb-gadget.service

${CHROOT_CMD} systemctl enable usb-gadget.service
