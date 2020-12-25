SRCROOT := $(realpath $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
TARGET_VERSION ?= focal
OBJDIR ?= $(SRCROOT)/build
ROOTDIR := $(OBJDIR)/rootfs
EXTERNAL_DIR := $(SRCROOT)/external
IMAGE_SIZE ?= 1600M
ROOTFS_SIZE ?= 1536M
INCLUDE_PACKAGES := kmod,linux-base,crda,initramfs-tools,locales,nano,pciutils,usbutils,net-tools,wget,curl,ethtool,vim,wireless-tools,wpasupplicant,openssh-server
BOOT_SIZE_BYTES = $(shell numfmt --from=iec $(BOOT_SIZE))
BOOT_SIZE_BLOCKS = $(shell expr $(BOOT_SIZE_BYTES) / 1024)
ROOTFS_FILE := $(OBJDIR)/rootfs.img
LOOPDEV := $(shell losetup -f)
FK_MACHINE := none

include $(SRCROOT)/board/$(PROFILE)/Makefile

export FK_MACHINE

.PHONY: all dirs bootloader rootfs rootfs-impl image

$(OBJDIR)/%:
	mkdir -p $@
	rsync --exclude='.git' -al $(EXTERNAL_DIR)/$(notdir $@)/ $@

rootfs: dirs
	unshare -m $(MAKE) rootfs-impl

rootfs-impl:
	qemu-debootstrap \
	    --arch=arm64 \
	    --include=$(INCLUDE_PACKAGES) \
	    $(TARGET_VERSION) \
	    $(ROOTDIR) || true

	rsync -avl $(SRCROOT)/files/ $(ROOTDIR)/
	chroot $(ROOTDIR) mount -t proc proc /proc
	chroot $(ROOTDIR) mount -t devpts devpts /dev/pts
	chroot $(ROOTDIR) apt-get -y update
	chroot $(ROOTDIR) apt-get -y dist-upgrade
	chroot $(ROOTDIR) apt-get -y install \
	    linux-image-unsigned-$(KERNEL_VERSION) \
	    linux-modules-$(KERNEL_VERSION) \
	    linux-modules-extra-$(KERNEL_VERSION)
	ln -sf \
	    /lib/firmware/$(KERNEL_VERSION)/device-tree/$(DEVICETREE_NAME) \
	    $(ROOTDIR)/boot/board.dtb
	echo "root:ubuntu" | chroot $(ROOTDIR) chpasswd

dirs:
	mkdir -p $(OBJDIR)
	mkdir -p $(ROOTDIR)

bootloader: $(BOOTLOADER_DEPENDS)

image: bootloader rootfs
	truncate -s $(IMAGE_SIZE) $(IMAGE_FILE)
	truncate -s $(ROOTFS_SIZE) $(ROOTFS_FILE)
	sgdisk -Z $(IMAGE_FILE)
	sgdisk -og $(IMAGE_FILE)
	sgdisk -n 1:$(BOOT_SIZE):0 -c 1:"ubuntu" $(IMAGE_FILE)
	mkfs.ext4 -F -d $(ROOTDIR) $(ROOTFS_FILE)
	dd if=$(OBJDIR)/rootfs.img of=$(IMAGE_FILE) seek=$(BOOT_SIZE_BLOCKS) bs=1024 conv=notrunc
	$(WRITE_BOOTLOADER)
