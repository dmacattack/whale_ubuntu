BOOT_SIZE := 32M
BOOTLOADER_DEPENDS := at91bootstrap3 u-boot
KERNEL_VERSION := 5.4.0-42-generic
DEVICETREE_NAME := freescale/fsl-ls1046a-whle.dtb

.PHONY: rcw atf u-boot fip qoriq-fm-ucode

define WRITE_BOOTLOADER
	dd if=$(AT91BOOTSTRAPB_PATH) of=$(IMAGE_FILE) bs=512 seek=8 conv=notrunc
	dd if=$(UBOOT_PATH) of=$(IMAGE_FILE) bs=512 seek=2048 conv=notrunc
endef

at91bootstrap3: $(OBJDIR)/at91bootstrap3
	$(MAKE) -C $< kstr_sama5d27_defconfig
	$(MAKE) -C $< CROSS_COMPILE=arm-linux-gnueabihf-

u-boot: $(OBJDIR)/u-boot
	$(MAKE) -C $< kstr_sama5d27_defconfig ARCH=arm
	$(MAKE) -C $< ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-

