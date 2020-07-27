BOOT_SIZE := 32M
BOOTLOADER_DEPENDS := rcw atf u-boot fip

define WRITE_BOOTLOADER
	dd if=$(OBJDIR)/atf/build/ls1046awhle/release/bl31.bin of=$(IMAGE_FILE) bs=512 skip=8
	dd if=$(OBJDIR)/atf/build/ls1046awhle/release/fip.bin of=$(IMAGE_FILE) bs=512 skip=2048
endef

define POST_IMAGE
	$(SRCROOT)/tools/fixup-gpt $(IMAGE_FILE)
endef

rcw: $(OBJDIR)/rcw
	$(MAKE) -C $</whle-ls1046a

atf: $(OBJDIR)/atf rcw
	$(MAKE) -C $< bl2 \
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

