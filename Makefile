SRCROOT := $(realpath $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
GITHASH := $(shell git rev-parse --short HEAD)
TARGET_VERSION ?= jammy
UBUNTU_VERSION ?= 22.04
OBJDIR ?= $(SRCROOT)/build-$(PROFILE)
SYSTEM_IMG_FILE ?= $(OBJDIR)/system.img
SYSTEM_IMG_SIZE ?= 2100M
ROOTFS_FILE := $(OBJDIR)/rootfs.img
ROOTFS_UUID := $(shell uuidgen)
ROOTFS_SIZE ?= 2000M
ROOTFS_LBA = $(call get_partition_start, $(SYSTEM_IMG_FILE), $(SYSTEM_PARTITION_INDEX))
BOOT_SIZE_BYTES = $(shell numfmt --from=iec $(BOOT_SIZE))
BOOT_SIZE_BLOCKS = $(shell expr $(BOOT_SIZE_BYTES) / 1024)
ROOTDIR := $(OBJDIR)/rootfs
EXTERNAL_DIR := $(SRCROOT)/external
INCLUDE_PACKAGES := $(shell cat $(SRCROOT)/config/packages | sed -z 's/\n/ /g')
CUSTOMIZE_SCRIPTS := $(notdir $(wildcard $(SRCROOT)/customize/*.sh))
CUSTOMIZE_TARGETS := $(sort $(addprefix $(OBJDIR)/.stamp-customize-, $(basename $(CUSTOMIZE_SCRIPTS))))
FK_MACHINE := none
CHROOT_CMD := chroot $(ROOTDIR)
BOARD_DIR := $(SRCROOT)/board/$(PROFILE)
PATH := $(PATH):$(OBJDIR)/bin
PACKAGE_DIR := $(OBJDIR)/package/$(TARGET_VERSION)
PACKAGE_NAME := ubuntu-$(PROFILE)-$(shell date +'%Y-%m-%d')-$(GITHASH)
GPT_MANIPULATOR := $(OBJDIR)/gpt-manipulator/bin/gpt-manipulator
TARGET_PATH ?=
EFI_MODE ?= no

include mk/utils.mk
include $(BOARD_DIR)/Makefile

export FK_MACHINE MACHINE_ARCH SRCROOT ROOTDIR ROOTFS_UUID
export CHROOT_CMD KERNEL_VARIANT DEVICETREE_NAME PROFILE
export UBUNTU_VERSION KERNEL_BOOTARGS BOARD_DIR PACKAGE_DIR PACKAGE_NAME PATH

.PHONY: all dirs bootloader rootfs rootfs-impl image flash clean __force
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
	$(CHROOT_CMD) apt-get -y autoremove
	$(call msg, Board customization)
	$(CUSTOMIZE_BOARD)

dirs:
	mkdir -p $(OBJDIR)
	mkdir -p $(ROOTDIR)

bootloader: $(addprefix $(OBJDIR)/.stamp-sync-,$(BOOTLOADER_MODULES)) $(BOOTLOADER_TARGETS)

$(ROOTFS_FILE): __force
	$(call msg, Prepare rootfs)
	truncate -s $(ROOTFS_SIZE) $@
	mkfs.ext4 -O ^metadata_csum -F -U $(ROOTFS_UUID) -d $(ROOTDIR) $@

$(SYSTEM_IMG_FILE):
	$(call msg, Prepare partitions)
	truncate -s $(SYSTEM_IMG_SIZE) $@
	sgdisk -Z $@
	$(GPT_MANIPULATOR) create $(SRCROOT)/board/$(PROFILE)/$(PARTITION_TABLE) $@

image: dirs bootloader gpt-manipulator rootfs $(CUSTOMIZE_TARGETS) $(ROOTFS_FILE) $(SYSTEM_IMG_FILE)
	$(call msg, Building system image)
	dd if=$(OBJDIR)/rootfs.img of=$(SYSTEM_IMG_FILE) seek=$(ROOTFS_LBA) bs=512 conv=notrunc
	$(WRITE_BOOTLOADER)

flash: __force
	dd if=$(SYSTEM_IMG_FILE) of=$(TARGET_PATH) bs=1M

clean:
	rm -rf $(OBJDIR)

package:
	mkdir -p $(PACKAGE_DIR)
	cp $(SYSTEM_IMG_FILE) $(PACKAGE_DIR)/$(PACKAGE_NAME).img
	cd $(PACKAGE_DIR) && sha256sum $(PACKAGE_NAME).img > $(PACKAGE_NAME).img.sha256sum
	cd $(PACKAGE_DIR) && xz -6 -T0 $(PACKAGE_NAME).img

gpt-manipulator:
	rsync --exclude='.git' -al external/gpt-manipulator $(OBJDIR)
	cd $(OBJDIR)/gpt-manipulator && cargo build --release
	cd $(OBJDIR)/gpt-manipulator && cargo install --path . --root $(@D)
