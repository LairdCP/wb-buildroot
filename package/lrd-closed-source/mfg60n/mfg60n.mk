#############################################################
#
# LMU
#
#############################################################
MFG60N_VERSION = local
MFG60N_SITE = package/lrd-closed-source/externals/mfg60n
MFG60N_SITE_METHOD = local
MFG60N_DEPENDENCIES = host-pkgconf libnl
MFG60N_MAKE_OPTS = CXX="$(TARGET_CXX)" CC="$(TARGET_CC)" LD="$(TARGET_LD)" LDFLAGS="$(TARGET_LDFLAGS)"
MFG60N_MAKE_ENV += $(TARGET_MAKE_ENV) \
	PKG_CONFIG="$(HOST_DIR)/usr/bin/pkg-config" \
	CFLAGS="$(TARGET_CFLAGS)" \
	AR="$(TARGET_AR)"

define MFG60N_BUILD_CMDS
	$(MFG60N_MAKE_ENV) $(MAKE) $(MFG60N_MAKE_OPTS) -C $(@D)/lmu
	$(MFG60N_MAKE_ENV) $(MAKE) $(MFG60N_MAKE_OPTS) -C $(@D)/wow
endef

define MFG60N_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/lmu/bin/lmu $(TARGET_DIR)/usr/bin/lmu
endef

define MFG60N_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/bin/lmu
endef

$(eval $(generic-package))
