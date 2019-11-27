# Generic Make engine for customer builds
# Customer external repositories should be using this Makefile

PACK_legacy = \
	at91bs.bin u-boot.bin kernel.bin rootfs.bin rootfs.tar.bz2 \
	userfs.bin sqroot.bin \
	fw_update fw_select fw_usi fw.txt prep_nand_for_update

PACK_sd60 = \
	u-boot-spl.bin u-boot.itb kernel.itb rootfs.tar \
	mksdcard.sh mksdimg.sh

PACK_nand60 = \
	boot.bin u-boot.itb kernel.itb rootfs.bin *.swu

PACK_nand60-secure = \
	boot.bin u-boot.itb kernel.itb rootfs.bin *.swu \
	pmecc.bin u-boot-spl.dtb u-boot-spl-nodtb.bin u-boot.dtb \
	u-boot-nodtb.bin u-boot.its kernel-nosig.itb sw-description \
	$(PRODUCT)-full.swu sw-description-full \
	fdtget fdtput mkimage genimage rodata.tar.bz2 rodata-encrypt

.PHONY: all clean
all: $(TARGETS)
clean: $(addsuffix -clean,$(TARGETS))

$(patsubst %,buildroot/output/%/.config,$(TARGETS)): buildroot/output/%/.config: $(BR2_EXTERNAL)/configs/%_defconfig
	$(MAKE) -C buildroot O=output/$* $*_defconfig

.PHONY: $(TARGETS)
$(TARGETS): %: buildroot/output/%/.config
	$(MAKE) -C buildroot O=output/$*

.PHONY: $(addsuffix -menuconfig,$(TARGETS))
$(addsuffix -menuconfig,$(TARGETS)): %-menuconfig: %-config
	$(MAKE) -C buildroot O=output/$* menuconfig

.PHONY: $(addsuffix -savedefconfig,$(TARGETS))
$(addsuffix -savedefconfig,$(TARGETS)): %-savedefconfig:
	$(MAKE) -C buildroot O=output/$* savedefconfig \
		BR2_DEFCONFIG=$(BR2_EXTERNAL)/configs/$*_defconfig

.PHONY: $(addsuffix -linux-menuconfig,$(TARGETS))
$(addsuffix -linux-menuconfig,$(TARGETS)): %-linux-menuconfig:
	$(MAKE) -C buildroot O=output/$* linux-menuconfig

.PHONY: $(addsuffix -linux-savedefconfig,$(TARGETS))
$(addsuffix -linux-savedefconfig,$(TARGETS)): %-linux-savedefconfig:
	$(MAKE) -C buildroot O=output/$* linux-update-defconfig

.PHONY: $(addsuffix -uboot-menuconfig,$(TARGETS))
$(addsuffix -uboot-menuconfig,$(TARGETS)): %:
	$(MAKE) -C buildroot O=output/$* uboot-menuconfig

.PHONY: $(addsuffix -uboot-savedefconfig,$(TARGETS))
$(addsuffix -uboot-savedefconfig,$(TARGETS)): %-uboot-savedefconfig:
	$(MAKE) -C buildroot O=output/$* uboot-update-defconfig

.PHONY: $(addsuffix -clean,$(TARGETS))
$(addsuffix -clean,$(TARGETS)): %-clean:
	$(MAKE) -C buildroot O=output/$* distclean

.PHONY: $(addsuffix -sdk,$(TARGETS))
$(addsuffix -sdk,$(TARGETS)): %-sdk:
	$(MAKE) -C buildroot O=output/$* sdk

.PHONY: $(addsuffix -pack,$(TARGETS))
$(addsuffix -pack,$(TARGETS)): %-pack:
	tar -C buildroot/output/$*/images -jcf $*-laird.tar.bz2 $(PACK_FILES_$*)
