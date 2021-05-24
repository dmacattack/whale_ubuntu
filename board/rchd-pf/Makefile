MACHINE_ARCH := riscv64
BOOT_SIZE := 32M
BOOTLOADER_TARGETS := u-boot payload
BOOTLOADER_MODULES := hart-software-services u-boot
DEVICETREE_NAME := microchip/mpfs-rchd-pf.dtb
KERNEL_VARIANT := rchd-pf
KERNEL_BOOTARGS := console=ttyS0,115200 root=/dev/mmcblk0p2 earlycon=sbi rootwait rw
UBOOT_PATH := $(OBJDIR)/u-boot/u-boot.bin
PAYLOAD_PATH := $(OBJDIR)/payload.bin
HSS_PAYLOAD_GENERATOR := $(OBJDIR)/hart-software-services/tools/hss-payload-generator
SYSTEM_PARTITION_INDEX := 2
PARTITION_TABLE := gpt.yml

.PHONY: hart-software-services u-boot payload

define WRITE_BOOTLOADER
	dd if=$(PAYLOAD_PATH) of=$(SYSTEM_IMG_FILE) bs=512 seek=34 conv=notrunc
endef

u-boot: $(OBJDIR)/u-boot
	$(call msg, Building U-Boot)
	$(MAKE) -C $< rchd_pf_defconfig
	$(MAKE) -C $< CROSS_COMPILE=riscv64-linux-gnu-
	cp $(UBOOT_PATH) $(OBJDIR)/u-boot-s.bin

payload: $(OBJDIR)/hart-software-services u-boot
	$(call msg, Building HSS payload)
	$(MAKE) -C $(HSS_PAYLOAD_GENERATOR) all
	cd $(OBJDIR) && $(HSS_PAYLOAD_GENERATOR)/hss-payload-generator \
	    -c $(BOARD_DIR)/hss.yml payload.bin
