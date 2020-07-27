SRCROOT := $(realpath $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
TARGET_VERSION ?= bionic
OBJDIR ?= $(SRCROOT)/build
SUDO ?= sudo -E
EXTERNAL_DIR := $(SRCROOT)/external
INCLUDE_PACKAGES := kmod,linux-base,crda,initramfs-tools
BOOT_SIZE_BYTES = $(shell numfmt --from=iec $(BOOT_SIZE))

include $(SRCROOT)/board/$(PROFILE)/Makefile

.PHONY: all dirs bootloader

$(OBJDIR)/%:
	rsync --exclude='.git' -al $(EXTERNAL_DIR)/$(notdir $@)/ $@ 

rootfs: dirs
	$(SUDO) qemu-debootstrap \
	    --arch=arm64 \
	    --include=$(INCLUDE_PACKAGES) \
	    $(TARGET_VERSION) \
	    $(OBJDIR)/rootfs

dirs:
	mkdir -p $(OBJDIR)
	mkdir -p $(OBJDIR)/rootfs

bootloader: $(BOOTLOADER_DEPENDS)

image: bootloader rootfs
	mkfs.ext4 -d $(OBJDIR)/rootfs -E offset=$(BOOT_SIZE_BYTES)
	sgdisk -og $(IMAGE_FILE)
	sgdisk -n 1:0:+$(BOOT_SIZE) -c 1:"boot" $(IMAGE_FILE)
	sgdisk -n 2:0:0 -c 2:"ubuntu" $(IMAGE_FILE)
	$(WRITE_BOOTLOADER)
	$(POST_IMAGE)

