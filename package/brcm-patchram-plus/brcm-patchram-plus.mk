################################################################################
#
# brcm-patchram-plus
#
################################################################################

BRCM_PATCHRAM_PLUS_VERSION = local
BRCM_PATCHRAM_PLUS_SITE = package/lrd/externals/brcm_patchram
BRCM_PATCHRAM_PLUS_SITE_METHOD = local

BRCM_PATCHRAM_PLUS_LICENSE = Apache-2.0
BRCM_PATCHRAM_PLUS_LICENSE_FILES = LICENSE

define BRCM_PATCHRAM_PLUS_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D) brcm_patchram_plus
endef

define BRCM_PATCHRAM_PLUS_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/brcm_patchram_plus $(TARGET_DIR)/usr/bin/
endef

$(eval $(generic-package))
