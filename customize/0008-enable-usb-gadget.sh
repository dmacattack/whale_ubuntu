#!/bin/sh

# This customization is optional as usb-gadget.service does not exist on every board.
OPTIONAL=1

mkdir -p ${ROOTDIR}/etc/modules-load.d/
touch ${ROOTDIR}/etc/modules-load.d/libcomposite.conf
/bin/sh -c 'echo "libcomposite"' >> ${ROOTDIR}/etc/modules-load.d/libcomposite.conf

${CHROOT_CMD} systemctl enable usb-gadget.service || [ $OPTIONAL ]

