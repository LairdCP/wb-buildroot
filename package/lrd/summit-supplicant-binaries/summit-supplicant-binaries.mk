ifneq ($(BR2_LRD_DEVEL_BUILD),y)

SUMMIT_SUPPLICANT_BINARIES_VERSION = 0.0.0.0
SUMMIT_SUPPLICANT_BINARIES_SOURCE =
SUMMIT_SUPPLICANT_BINARIES_LICENSE = GPL-2.0
SUMMIT_SUPPLICANT_BINARIES_EXTRA_DOWNLOADS = summit_supplicant-arm-eabihf-$(SUMMIT_SUPPLICANT_BINARIES_VERSION).tar.bz2

ifeq ($(MSD_BINARIES_SOURCE_LOCATION),laird_internal)
  SUMMIT_SUPPLICANT_BINARIES_SITE = http://devops.lairdtech.com/share/builds/linux/summit_supplicant/laird/$(SUMMIT_SUPPLICANT_BINARIES_VERSION)
else
  SUMMIT_SUPPLICANT_BINARIES_SITE = https://github.com/LairdCP/wb-package-archive/releases/download/LRD-REL-$(SUMMIT_SUPPLICANT_BINARIES_VERSION)
endif

define SUMMIT_SUPPLICANT_BINARIES_INSTALL_TARGET_CMDS
	tar -xjf $(DL_DIR)/summit-supplicant-binaries/$(SUMMIT_SUPPLICANT_BINARIES_EXTRA_DOWNLOADS) -C $(TARGET_DIR) --keep-directory-symlink --no-overwrite-dir --touch
endef

endif

$(eval $(generic-package))
