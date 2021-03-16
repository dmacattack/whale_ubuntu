MACHINE_ARCH := armhf
BOOT_SIZE := 32M
BOOTLOADER_DEPENDS := at91bootstrap u-boot
KERNEL_VERSION := 5.4.0-42-generic
DEVICETREE_NAME := at91-kstr-sama5d27.dtb
KERNEL_VARIANT := kstr-sama5d27
AT91BOOTSTRAP_PATH := $(OBJDIR)/at91bootstrap/xxx
UBOOT_PATH := $(OBJDIR)/u-boot/u-boot.bin
SYSTEM_PARTITION_INDEX := 2
PARTITION_TABLE := gpt.yml

.PHONY: at91bootstrap u-boot

define WRITE_BOOTLOADER
	truncate -s 8M $(OBJDIR)/boot.img
	mkfs.fat $(OBJDIR)/boot.img
	mcopy -i $(OBJDIR)/boot.img $(AT91BOOTSTRAP_PATH) ::boot.bin
	mcopy -i $(OBJDIR)/boot.img $(UBOOT_PATH) ::u-boot.bin
	dd if=$(OBJDIR)/boot.img of=$(IMAGE_FILE) bs=512 seek=34 conv=notrunc
endef

at91bootstrap: $(OBJDIR)/at91bootstrap
	$(MAKE) -C $< kstr_sama5d27_defconfig
	$(MAKE) -C $< CROSS_COMPILE=arm-linux-gnueabihf-

u-boot: $(OBJDIR)/u-boot
	$(MAKE) -C $< kstr_sama5d27_defconfig ARCH=arm
	$(MAKE) -C $< ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-
