MACHINE_ARCH := armhf
BOOT_SIZE := 16M
BOOTLOADER_TARGETS := at91bootstrap u-boot
BOOTLOADER_MODULES := at91bootstrap u-boot
DEVICETREE_NAME := at91-kstr-sama5d27.dtb
KERNEL_VARIANT := kstr-sama5d27
KERNEL_BOOTARGS := console=ttyS0,115200 earlyprintk root=/dev/mmcblk0p2 rw rootwait
BOOT_PARTITION_INDEX := 1
SYSTEM_PARTITION_INDEX := 2
PARTITION_TABLE := gpt.yml
BOOT_LBA = $(call get_partition_start, $(SYSTEM_IMG_FILE), $(BOOT_PARTITION_INDEX))
AT91BOOTSTRAP_PATH := $(OBJDIR)/at91bootstrap/binaries/boot.bin
UBOOT_PATH := $(OBJDIR)/u-boot/u-boot.bin

.PHONY: at91bootstrap u-boot

define WRITE_BOOTLOADER
	$(call msg, Preparing boot.img)
	truncate -s $(BOOT_SIZE) $(OBJDIR)/boot.img
	mkfs.fat -F16 -I $(OBJDIR)/boot.img
	mcopy -i $(OBJDIR)/boot.img $(UBOOT_PATH) ::u-boot.bin
	mcopy -i $(OBJDIR)/boot.img $(AT91BOOTSTRAP_PATH) ::boot.bin
	dd if=$(OBJDIR)/boot.img of=$(SYSTEM_IMG_FILE) bs=512 seek=$(BOOT_LBA) conv=notrunc
endef

at91bootstrap: $(OBJDIR)/at91bootstrap
	$(call msg, Building AT91Bootstrap)
	$(MAKE) -C $< CROSS_COMPILE=arm-linux-gnueabihf- kstr_sama5d27sd_uboot_defconfig
	$(MAKE) -C $< CROSS_COMPILE=arm-linux-gnueabihf-
	cp $(AT91BOOTSTRAP_PATH) $(OBJDIR)/boot.bin

u-boot: $(OBJDIR)/u-boot
	$(call msg, Building U-Boot)
	$(MAKE) -C $< ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- kstr_sama5d27_defconfig
	$(MAKE) -C $< ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-

define CUSTOMIZE_BOARD
	$(call msg, Install wifi firmware files)
	cp -r $(BOARD_DIR)/firmware/ ${ROOTDIR}/usr/lib/
	cp -r $(BOARD_DIR)/opt/ ${ROOTDIR}
endef
