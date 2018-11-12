ifeq ($(BR2_LRD_DEVEL_BUILD),y)
else
SUMMIT_SUPPLICANT_BINARIES_VERSION = 0.0.0.0
SUMMIT_SUPPLICANT_BINARIES_SOURCE = summit_supplicant-arm-eabihf-$(SUMMIT_SUPPLICANT_BINARIES_VERSION).tar.bz2
SUMMIT_SUPPLICANT_BINARIES_LICENSE = GPL-2.0
SUMMIT_SUPPLICANT_BINARIES_SITE = https://github.com/LairdCP/wb-package-archive/raw/master

define SUMMIT_SUPPLICANT_BINARIES_INSTALL_TARGET_CMDS
	tar -xf $(@D)/rootfs.tar -C $(TARGET_DIR) --overwrite
endef
endif

$(eval $(generic-package))
