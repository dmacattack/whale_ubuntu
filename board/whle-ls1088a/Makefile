MACHINE_ARCH := arm64
BOOT_SIZE := 32M
BOOTLOADER_TARGETS := atf fip qoriq-mc-binary mc-utils
BOOTLOADER_MODULES := rcw atf u-boot qoriq-mc-binary mc-utils
DEVICETREE_NAME := freescale/fsl-ls1088a-whle.dtb
KERNEL_VARIANT := whle-ls1
KERNEL_BOOTARGS := console=ttyS0,115200 root=/dev/mmcblk0p1 earlycon=uart8250,mmio,0x21c0500 rootwait rw
BL2_PATH := $(OBJDIR)/atf/build/ls1088awhle/release/bl2_emmc.pbl
FIP_PATH := $(OBJDIR)/atf/build/ls1088awhle/release/fip.bin
MC_FW_PATH := $(OBJDIR)/qoriq-mc-binary/ls1088a/mc_ls1088a_10.30.0.itb
DPAA2_DPL_PATH := $(OBJDIR)/mc-utils/config/ls1088a/WHLE-LS1088A/dpl-eth.0x1D_0x0D.dts
DPAA2_DPC_PATH := $(OBJDIR)/mc-utils/config/ls1088a/WHLE-LS1088A/dpc.0x1D-0x0D.dts
SYSTEM_PARTITION_INDEX := 1
PARTITION_TABLE := gpt.yml

.PHONY: rcw atf u-boot fip qoriq-fm-ucode

define WRITE_BOOTLOADER
	dd if=$(BL2_PATH) of=$(SYSTEM_IMG_FILE) bs=512 seek=8 conv=notrunc
	dd if=$(FIP_PATH) of=$(SYSTEM_IMG_FILE) bs=512 seek=2048 conv=notrunc
	dd if=$(MC_FW_PATH) of=$(SYSTEM_IMG_FILE) bs=512 seek=20480 conv=notrunc
	dd if=$(DPAA2_DPL_PATH) of=$(SYSTEM_IMG_FILE) bs=512 seek=26624 conv=notrunc
	dd if=$(DPAA2_DPC_PATH) of=$(SYSTEM_IMG_FILE) bs=512 seek=28672 conv=notrunc
endef

rcw: $(OBJDIR)/rcw
	$(call msg, Building RCW)
	$(MAKE) -C $</whle-ls1088a

atf: $(OBJDIR)/atf rcw
	$(call msg, Building ARM Trusted Firmware)
	$(MAKE) -C $< pbl \
	    PLAT=ls1088awhle \
	    BOOT_MODE=emmc \
	    RCW=../rcw/whle-ls1088a/FFSSRR_PPP_0x1d_0x14/rcw_1400_sdboot.bin \
	    CROSS_COMPILE=aarch64-linux-gnu-

u-boot: $(OBJDIR)/u-boot
	$(call msg, Building U-Boot)
	$(MAKE) -C $< whle_ls1088a_defconfig
	$(MAKE) -C $< CROSS_COMPILE=aarch64-linux-gnu-

fip: $(OBJDIR)/atf atf u-boot
	$(call msg, Building FIP image)
	$(MAKE) -C $< fip \
	    PLAT=ls1088awhle \
	    BL33=../u-boot/u-boot.bin \
	    CROSS_COMPILE=aarch64-linux-gnu-

qoriq-mc-binary: $(OBJDIR)/qoriq-mc-binary
	true

mc-utils: $(OBJDIR)/mc-utils
	$(MAKE) -C $</config
