BOOT_SIZE := 32M
BOOTLOADER_DEPENDS := rcw atf u-boot fip qoriq-fm-ucode
KERNEL_VERSION := 5.4.0-43-generic
DEVICETREE_NAME := freescale/fsl-ls1046a-whle.dtb
BL2_PATH := $(OBJDIR)/atf/build/ls1046awhle/release/bl2_emmc.pbl
FIP_PATH := $(OBJDIR)/atf/build/ls1046awhle/release/fip.bin
FMAN_FW_PATH := $(OBJDIR)/qoriq-fm-ucode/fsl_fman_ucode_ls1046_r1.0_106_4_18.bin

.PHONY: rcw atf u-boot fip qoriq-fm-ucode

define WRITE_BOOTLOADER
	$(SRCROOT)/tools/fixup-gpt $(IMAGE_FILE)
	dd if=$(BL2_PATH) of=$(IMAGE_FILE) bs=512 seek=8 conv=notrunc
	dd if=$(FIP_PATH) of=$(IMAGE_FILE) bs=512 seek=2048 conv=notrunc
	dd if=$(FMAN_FW_PATH) of=$(IMAGE_FILE) bs=512 seek=18432 conv=notrunc
endef

rcw: $(OBJDIR)/rcw
	$(MAKE) -C $</whle-ls1046a

atf: $(OBJDIR)/atf rcw
	$(MAKE) -C $< pbl \
	    PLAT=ls1046awhle \
	    BOOT_MODE=emmc \
	    RCW=../rcw/whle-ls1046a/NN_SSFFPPPP_1133_5577/rcw_1600_sdboot.bin \
	    CROSS_COMPILE=aarch64-linux-gnu-

u-boot: $(OBJDIR)/u-boot
	$(MAKE) -C $< whle_ls1046a_defconfig ARCH=arm
	$(MAKE) -C $< ARCH=arm CROSS_COMPILE=aarch64-linux-gnu-

fip: $(OBJDIR)/atf u-boot
	$(MAKE) -C $< fip \
	    PLAT=ls1046awhle \
	    BL33=../u-boot/u-boot.bin \
	    CROSS_COMPILE=aarch64-linux-gnu-

qoriq-fm-ucode: $(OBJDIR)/qoriq-fm-ucode
	true
