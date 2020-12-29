SRCROOT := $(realpath $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
TARGET_VERSION ?= focal
OBJDIR ?= $(SRCROOT)/build-$(PROFILE)
ROOTDIR := $(OBJDIR)/rootfs
IMAGE_FILE ?= $(OBJDIR)/system.img
EXTERNAL_DIR := $(SRCROOT)/external
IMAGE_SIZE ?= 1600M
ROOTFS_SIZE ?= 1536M
INCLUDE_PACKAGES := $(shell cat $(SRCROOT)/config/packages | sed -z 's/\n/ /g')
BOOT_SIZE_BYTES = $(shell numfmt --from=iec $(BOOT_SIZE))
BOOT_SIZE_BLOCKS = $(shell expr $(BOOT_SIZE_BYTES) / 1024)
ROOTFS_FILE := $(OBJDIR)/rootfs.img
ROOTFS_UUID := $(shell uuidgen)
CUSTOMIZE_SCRIPTS := $(notdir $(wildcard $(SRCROOT)/customize/*.sh))
CUSTOMIZE_TARGETS := $(sort $(addprefix $(OBJDIR)/.stamp-customize-, $(basename $(CUSTOMIZE_SCRIPTS))))
FK_MACHINE := none
CHROOT_CMD := chroot $(ROOTDIR)

include mk/utils.mk
include $(SRCROOT)/board/$(PROFILE)/Makefile

export FK_MACHINE MACHINE_ARCH SRCROOT ROOTDIR ROOTFS_UUID
export CHROOT_CMD

.PHONY: all dirs bootloader rootfs rootfs-impl image

$(OBJDIR)/.stamp-sync-%: external/%
	$(call msg, Syncing $<)
	mkdir -p $(OBJDIR)/$(<F)
	rsync --exclude='.git' -al $< $(OBJDIR)/$(<F)
	touch $@

$(OBJDIR)/.stamp-customize-%: customize/%.sh
	$(call msg, Running customize script $(<F))
	sh $<
	touch $@

rootfs: dirs
	unshare -m $(MAKE) rootfs-impl

rootfs-impl:
	$(call msg, Building root filesystem)
	qemu-debootstrap \
	    --arch=$(MACHINE_ARCH) \
	    $(TARGET_VERSION) \
	    $(ROOTDIR) || true

	rsync -avl $(SRCROOT)/files/ $(ROOTDIR)/
	$(CHROOT_CMD) mount -t proc proc /proc
	$(CHROOT_CMD) mount -t devpts devpts /dev/pts
	$(CHROOT_CMD) apt-get -y update
	$(CHROOT_CMD) apt-get -y dist-upgrade
	$(CHROOT_CMD) $(call apt_get, $(INCLUDE_PACKAGES))
	$(CHROOT_CMD) $(call apt_get, linux-image-$(KERNEL_VARIANT))
	#chroot $(ROOTDIR) linux-update-symlinks install $(KERNEL_VERSION) /boot/vmlinuz-$(KERNEL_VERSION)
	#ln -sf \
	#    /usr/lib/$(KERNEL_VERSION)/$(DEVICETREE_NAME) \
	#    $(ROOTDIR)/boot/board.dtb

dirs:
	mkdir -p $(OBJDIR)
	mkdir -p $(ROOTDIR)

bootloader: $(addprefix $(OBJDIR)/.stamp-sync-,$(BOOTLOADER_MODULES)) $(BOOTLOADER_TARGETS)

image: bootloader rootfs $(CUSTOMIZE_TARGETS)
	$(call msg, Building system image)
	truncate -s $(IMAGE_SIZE) $(IMAGE_FILE)
	truncate -s $(ROOTFS_SIZE) $(ROOTFS_FILE)
	sgdisk -Z $(IMAGE_FILE)
	sgdisk -og $(IMAGE_FILE)
	sgdisk -n 1:$(BOOT_SIZE):0 -c 1:"ubuntu" $(IMAGE_FILE)
	mkfs.ext4 -F -U $(ROOTFS_UUID) -d $(ROOTDIR) $(ROOTFS_FILE)
	dd if=$(OBJDIR)/rootfs.img of=$(IMAGE_FILE) seek=$(BOOT_SIZE_BLOCKS) bs=1024 conv=notrunc
	$(WRITE_BOOTLOADER)
