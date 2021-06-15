#!/bin/sh

${CHROOT_CMD} /bin/sh -c 'echo "PermitRootLogin yes"' >> ${ROOTDIR}/etc/ssh/sshd_config
