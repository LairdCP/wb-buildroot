#############################################################
#
# patchram program
#
#############################################################

# source included in buildroot
PATCHRAM_VERSION = local
PATCHRAM_SOURCE =

define PATCHRAM_BUILD_CMDS
	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
		package/lrd/patchram/brcm_patchram_plus.c -o $(@D)/patchram
endef

define PATCHRAM_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/patchram $(TARGET_DIR)/usr/bin/
endef

define PATCHRAM_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/bin/patchram
endef

$(eval $(generic-package))