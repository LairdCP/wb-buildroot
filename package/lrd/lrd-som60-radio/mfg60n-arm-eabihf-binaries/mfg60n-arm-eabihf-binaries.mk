MFG60N_ARM_EABIHF_BINARIES_VERSION = $(call qstrip,$(BR2_PACKAGE_LRD_RADIO_STACK_VERSION_VALUE))
MFG60N_ARM_EABIHF_BINARIES_SOURCE =
MFG60N_ARM_EABIHF_BINARIES_LICENSE = GPL-2.0
MFG60N_ARM_EABIHF_BINARIES_EXTRA_DOWNLOADS = mfg60n-arm-eabihf-$(MFG60N_ARM_EABIHF_BINARIES_VERSION).tar.bz2

ifeq ($(MSD_BINARIES_SOURCE_LOCATION),laird_internal)
  MFG60N_ARM_EABIHF_BINARIES_SITE = https://files.devops.rfpros.com/builds/linux/mfg60n/laird/$(MFG60N_ARM_EABIHF_BINARIES_VERSION)
  ifeq ($(shell wget -q --spider $(MFG60N_ARM_EABIHF_BINARIES_SITE) && echo ok),)
	  MFG60N_ARM_EABIHF_BINARIES_SITE = https://files.devops.rfpros.com/builds/linux/mfg60n/laird/$(MFG60N_ARM_EABIHF_BINARIES_VERSION)
  endif
else
  MFG60N_ARM_EABIHF_BINARIES_SITE = https://github.com/LairdCP/wb-package-archive/releases/download/LRD-REL-$(MFG60N_ARM_EABIHF_BINARIES_VERSION)
endif

define MFG60N_ARM_EABIHF_BINARIES_EXTRACT_CMDS
	tar -xjf $($(PKG)_DL_DIR)/$(MFG60N_ARM_EABIHF_BINARIES_EXTRA_DOWNLOADS) -C $(@D) --keep-directory-symlink --no-overwrite-dir --touch
	(cd $(@D) && ./mfg60n-arm-eabihf-$(MFG60N_ARM_EABIHF_BINARIES_VERSION).sh tar && mkdir -p files)
	tar -xvjf $(@D)/mfg60n-arm-eabihf-$(MFG60N_ARM_EABIHF_BINARIES_VERSION).tar.bz2 -C $(@D)/files/
endef

define MFG60N_ARM_EABIHF_BINARIES_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/files/lmu $(TARGET_DIR)/usr/bin/lmu
	$(INSTALL) -D -m 755 $(@D)/files/lru $(TARGET_DIR)/usr/bin/lru
	$(INSTALL) -D -m 755 $(@D)/files/btlru $(TARGET_DIR)/usr/bin/btlru
	$(INSTALL) -D -m 644 $(@D)/files/88W8997_mfg* -t $(TARGET_DIR)/lib/firmware/lrdmwl/
endef

$(eval $(generic-package))
