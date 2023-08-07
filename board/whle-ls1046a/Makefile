MACHINE_ARCH := arm64
BOOT_SIZE := 32M
BOOTLOADER_TARGETS := atf fip qoriq-fm-ucode
BOOTLOADER_MODULES := rcw atf u-boot qoriq-fm-ucode
DEVICETREE_NAME := freescale/fsl-ls1046a-whle.dtb
KERNEL_VARIANT := whle-ls1
KERNEL_BOOTARGS := console=ttyS0,115200 root=/dev/mmcblk0p1 earlycon=uart8250,mmio,0x21c0500 rootwait rw
BL2_PATH := $(OBJDIR)/atf/build/ls1046awhle/release/bl2_emmc.pbl
FIP_PATH := $(OBJDIR)/atf/build/ls1046awhle/release/fip.bin
FMAN_FW_PATH := $(OBJDIR)/qoriq-fm-ucode/fsl_fman_ucode_ls1046_r1.0_106_4_18.bin
SYSTEM_PARTITION_INDEX := 1
PARTITION_TABLE := gpt.yml
SUPPORTS_EFI_MODE := yes

.PHONY: rcw atf u-boot fip qoriq-fm-ucode

define WRITE_BOOTLOADER
	dd if=$(BL2_PATH) of=$(SYSTEM_IMG_FILE) bs=512 seek=8 conv=notrunc
	dd if=$(FIP_PATH) of=$(SYSTEM_IMG_FILE) bs=512 seek=2048 conv=notrunc
	dd if=$(FMAN_FW_PATH) of=$(SYSTEM_IMG_FILE) bs=512 seek=18432 conv=notrunc
endef

rcw: $(OBJDIR)/rcw
	$(call msg, Building RCW)
	$(MAKE) -C $</whle-ls1046a

atf: $(OBJDIR)/atf rcw
	$(call msg, Building ARM Trusted Firmware)
	$(MAKE) -C $< pbl \
	    PLAT=ls1046awhle \
	    BOOT_MODE=emmc \
	    POLICY_OTA=0 \
	    RCW=../rcw/whle-ls1046a/NN_SSFFPPPP_1133_5577/rcw_1800_emmc.bin \
	    CROSS_COMPILE=aarch64-linux-gnu-

u-boot: $(OBJDIR)/u-boot
	$(call msg, Building U-Boot)
	$(MAKE) -C $< whle_ls1046a_emmc_defconfig
	$(MAKE) -C $< CROSS_COMPILE=aarch64-linux-gnu-

fip: $(OBJDIR)/atf atf u-boot
	$(call msg, Building FIP image)
	$(MAKE) -C $< fip \
	    PLAT=ls1046awhle \
	    BL33=../u-boot/u-boot.bin \
	    CROSS_COMPILE=aarch64-linux-gnu-

qoriq-fm-ucode: $(OBJDIR)/qoriq-fm-ucode
	true
