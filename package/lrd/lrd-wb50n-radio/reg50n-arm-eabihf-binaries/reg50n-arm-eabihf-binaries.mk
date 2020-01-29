REG50N_ARM_EABIHF_BINARIES_VERSION = $(call qstrip,$(BR2_PACKAGE_LRD_RADIO_STACK_VERSION_VALUE))
REG50N_ARM_EABIHF_BINARIES_SOURCE =
REG50N_ARM_EABIHF_BINARIES_LICENSE = GPL-2.0
REG50N_ARM_EABIHF_BINARIES_EXTRA_DOWNLOADS = reg50n-arm-eabihf-laird-$(REG50N_ARM_EABIHF_BINARIES_VERSION).tar.bz2

REG50N_ARM_EABIHF_BINARIES_SITE = https://files.devops.rfpros.com/builds/linux/reg50n/laird/$(REG50N_ARM_EABIHF_BINARIES_VERSION)
ifeq ($(shell wget -q --spider $(REG50N_ARM_EABIHF_BINARIES_SITE) && echo ok),)
  REG50N_ARM_EABIHF_BINARIES_SITE = https://files.devops.rfpros.com/builds/linux/reg50n-arm-eabihf/laird/$(REG50N_ARM_EABIHF_BINARIES_VERSION)
endif

define REG50N_ARM_EABIHF_BINARIES_EXTRACT_CMDS
	tar -xjf $($(PKG)_DL_DIR)/$(REG50N_ARM_EABIHF_BINARIES_EXTRA_DOWNLOADS) -C $(@D) --keep-directory-symlink --no-overwrite-dir --touch
	(cd $(@D) && ./reg50n-$(REG50N_ARM_EABIHF_BINARIES_VERSION).sh tar && mkdir -p files)
	tar -xvjf $(@D)/reg50n-$(REG50N_ARM_EABIHF_BINARIES_VERSION).tar.bz2 -C $(@D)/files/
endef

define REG50N_ARM_EABIHF_BINARIES_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/files/lru $(TARGET_DIR)/usr/bin/lru
	$(INSTALL) -D -m 755 $(@D)/files/smu_cli $(TARGET_DIR)/usr/bin/smu_cli
	$(INSTALL) -D -m 644 $(@D)/files/utf*.bin -t $(TARGET_DIR)/lib/firmware/ath6k/AR6004/hw3.0/
	$(INSTALL) -D -m 755 $(@D)/files/tcmd.sh $(TARGET_DIR)/usr/bin/tcmd.sh
endef

$(eval $(generic-package))
