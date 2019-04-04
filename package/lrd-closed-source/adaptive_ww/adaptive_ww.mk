#############################################################
#
# 60 Series Adaptive World Mode Daemon
#
#############################################################
ADAPTIVE_WW_VERSION = local
ADAPTIVE_WW_SITE = package/lrd-closed-source/externals/adaptive_ww
ADAPTIVE_WW_SITE_METHOD = local
ADAPTIVE_WW_DEPENDENCIES = host-pkgconf libnl libopenssl

MY_MAKE_OPTS = CXX="$(TARGET_CXX)" CC="$(TARGET_CC)" LD="$(TARGET_LD)" PKG_CONFIG="$(HOST_DIR)/usr/bin/pkg-config"

#
# BUILD
#
define ADAPTIVE_WW_BUILD_CMDS
	$(MAKE) $(MY_MAKE_OPTS) -C $(@D)
endef

#
#Install
#
define ADAPTIVE_WW_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/bin/adaptive_ww $(TARGET_DIR)/usr/bin/adaptive_ww
endef


#
# Uninstall
#
define ADAPTIVE_WW_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/bin/adaptive_ww
endef

$(eval $(generic-package))
