#!/bin/sh

SENTINEL=/var/lib/rootfs-resized
if [ -f $SENTINEL ]; then
    echo "$SENTINEL exists - was the root partition already resized?"
    exit
fi

PARTNAME=$(lsblk -o mountpoint,kname,pkname | grep -e "^/\s.*" | tr -s ' ' | cut -d ' ' -f2)
DEVNAME=$(lsblk -o mountpoint,kname,pkname | grep -e "^/\s.*" | tr -s ' ' | cut -d ' ' -f3)
START=$(cat /sys/block/$DEVNAME/$PARTNAME/start)

growpart /dev/$DEVNAME 1

partprobe /dev/$DEVNAME
resize2fs /dev/$PARTNAME

touch $SENTINEL

