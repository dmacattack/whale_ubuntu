SRCROOT := $(realpath $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
TARGET_VERSION ?= focal
UBUNTU_VERSION ?= 20.04
OBJDIR ?= $(SRCROOT)/build-$(PROFILE)
ROOTDIR := $(OBJDIR)/rootfs
IMAGE_FILE ?= $(OBJDIR)/system.img
EXTERNAL_DIR := $(SRCROOT)/external
IMAGE_SIZE ?= 1600M
ROOTFS_SIZE ?= 1536M
ROOTFS_LBA = $(call get_partition_start, $(IMAGE_FILE), $(SYSTEM_PARTITION_INDEX))
INCLUDE_PACKAGES := $(shell cat $(SRCROOT)/config/packages | sed -z 's/\n/ /g')
BOOT_SIZE_BYTES = $(shell numfmt --from=iec $(BOOT_SIZE))
BOOT_SIZE_BLOCKS = $(shell expr $(BOOT_SIZE_BYTES) / 1024)
ROOTFS_FILE := $(OBJDIR)/rootfs.img
ROOTFS_UUID := $(shell uuidgen)
CUSTOMIZE_SCRIPTS := $(notdir $(wildcard $(SRCROOT)/customize/*.sh))
CUSTOMIZE_TARGETS := $(sort $(addprefix $(OBJDIR)/.stamp-customize-, $(basename $(CUSTOMIZE_SCRIPTS))))
FK_MACHINE := none
CHROOT_CMD := chroot $(ROOTDIR)
BOARD_DIR := $(SRCROOT)/board/$(PROFILE)
PATH := $(PATH):$(OBJDIR)/bin

include mk/utils.mk
include $(BOARD_DIR)/Makefile

export FK_MACHINE MACHINE_ARCH SRCROOT ROOTDIR ROOTFS_UUID
export CHROOT_CMD KERNEL_VARIANT DEVICETREE_NAME PROFILE
export UBUNTU_VERSION KERNEL_BOOTARGS BOARD_DIR PATH

.PHONY: all dirs bootloader rootfs rootfs-impl image __force
__force:

$(OBJDIR)/.stamp-sync-%: external/% __force
	$(call msg, Syncing $<)
	mkdir -p $(OBJDIR)/$(<F)
	rsync --exclude='.git' -al $</ $(OBJDIR)/$(<F)
	touch $@

$(OBJDIR)/.stamp-customize-%: customize/%.sh __force
	$(call msg, Running customize script $(<F))
	sh -e $<
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

$(ROOTFS_FILE): rootfs
	truncate -s $(ROOTFS_SIZE) $@
	mkfs.ext4 -F -U $(ROOTFS_UUID) -d $(ROOTDIR) $@

$(IMAGE_FILE): $(SRCROOT)/board/$(PROFILE)/$(PARTITION_TABLE)
	truncate -s $(IMAGE_SIZE) $@
	sgdisk -Z $@
	gpt-manipulator $@ -c $<

image: bootloader gpt-manipulator $(ROOTFS_FILE) $(CUSTOMIZE_TARGETS) $(IMAGE_FILE)
	$(call msg, Building system image)
	dd if=$(OBJDIR)/rootfs.img of=$(IMAGE_FILE) seek=$(ROOTFS_LBA) bs=512 conv=notrunc
	$(WRITE_BOOTLOADER)

gpt-manipulator: $(OBJDIR)/gpt-manipulator

$(OBJDIR)/gpt-manipulator: $(SRCROOT)/external/gpt-manipulator
	cd $< && cargo build --release
	cd $< && cargo install --path . --root $(@D)
