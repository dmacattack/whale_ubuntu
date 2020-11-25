SRCROOT := $(realpath $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
TARGET_VERSION ?= bionic
OBJDIR ?= $(SRCROOT)/build
EXTERNAL_DIR := $(SRCROOT)/external
INCLUDE_PACKAGES := kmod,linux-base,crda,initramfs-tools
BOOT_SIZE_BYTES = $(shell numfmt --from=iec $(BOOT_SIZE))
LOOPDEV := $(shell losetup -f)

include $(SRCROOT)/board/$(PROFILE)/Makefile

.PHONY: all dirs bootloader

$(OBJDIR)/%:
	mkdir -p $@ && rsync --exclude='.git' -al $(EXTERNAL_DIR)/$(notdir $@)/ $@

rootfs: dirs
	qemu-debootstrap \
	    --arch=arm64 \
	    --include=$(INCLUDE_PACKAGES) \
	    $(TARGET_VERSION) \
	    $(OBJDIR)/rootfs || true

dirs:
	mkdir -p $(OBJDIR)
	mkdir -p $(OBJDIR)/rootfs

bootloader: $(BOOTLOADER_DEPENDS)

image: bootloader rootfs
	truncate -s $(IMAGE_SIZE) $(IMAGE_FILE)
	sgdisk -og $(IMAGE_FILE)
	sgdisk -n 1:$(BOOT_SIZE):0 -c 1:"ubuntu" $(IMAGE_FILE)
	$(WRITE_BOOTLOADER)
	losetup -P $(LOOPDEV) $(IMAGE_FILE)
	mkfs.ext4 -d $(OBJDIR)/rootfs $(LOOPDEV)p1
	losetup -d $(LOOPDEV)
