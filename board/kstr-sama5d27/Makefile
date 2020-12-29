MACHINE_ARCH := armhf
BOOT_SIZE := 32M
BOOTLOADER_DEPENDS := at91bootstrap u-boot
KERNEL_VERSION := 5.4.0-42-generic
DEVICETREE_NAME := at91-kstr-sama5d27.dtb
KERNEL_VARIANT := kstr-sama5d27
SYSTEM_PARTITION_INDEX := 2

.PHONY: at91bootstrap u-boot

define PARTITION_SCRIPT
	sgdisk -n 1::$(BOOT_SIZE) -c 1:"boot" -t 1:0c00 $(1)
	sgdisk -n 2:: -c 2:"system" -t 2:8300 $(1)
	sgdisk -h 1:EE $(1)
endef

define WRITE_BOOTLOADER
	dd if=$(AT91BOOTSTRAPB_PATH) of=$(IMAGE_FILE) bs=512 seek=8 conv=notrunc
	dd if=$(UBOOT_PATH) of=$(IMAGE_FILE) bs=512 seek=64 conv=notrunc
endef

at91bootstrap: $(OBJDIR)/at91bootstrap
	$(MAKE) -C $< kstr_sama5d27_defconfig
	$(MAKE) -C $< CROSS_COMPILE=arm-linux-gnueabihf-

u-boot: $(OBJDIR)/u-boot
	$(MAKE) -C $< kstr_sama5d27_defconfig ARCH=arm
	$(MAKE) -C $< ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-

