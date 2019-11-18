ifneq ($(BR2_LRD_DEVEL_BUILD),y)
ADAPTIVE_WW_BINARIES_VERSION = $(call qstrip,$(BR2_PACKAGE_LRD_RADIO_STACK_VERSION_VALUE))
ADAPTIVE_WW_BINARIES_SOURCE =
ADAPTIVE_WW_BINARIES_LICENSE = LGPL-2.1
ADAPTIVE_WW_BINARIES_EXTRA_DOWNLOADS = adaptive_ww-arm-eabihf-$(ADAPTIVE_WW_BINARIES_VERSION).tar.bz2

ifeq ($(MSD_BINARIES_SOURCE_LOCATION),laird_internal)
  ADAPTIVE_WW_BINARIES_SITE = https://files.devops.rfpros.com/builds/linux/adaptive_ww/laird/$(ADAPTIVE_WW_BINARIES_VERSION)
else
  ADAPTIVE_WW_BINARIES_SITE = https://github.com/LairdCP/SOM60-Release-Packages/releases/download/LRD-REL-$(ADAPTIVE_WW_BINARIES_VERSION)
endif

define ADAPTIVE_WW_BINARIES_INSTALL_TARGET_CMDS
	tar -xjf $($(PKG)_DL_DIR)/$(ADAPTIVE_WW_BINARIES_EXTRA_DOWNLOADS) -C $(TARGET_DIR) --keep-directory-symlink --no-overwrite-dir --touch
endef

endif

$(eval $(generic-package))
