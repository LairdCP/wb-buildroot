#############################################################
#
# 60 Series Adaptive World Mode Daemon
#
#############################################################
ADAPTIVE_WW_VERSION = local
ADAPTIVE_WW_SITE = package/lrd-closed-source/externals/adaptive_ww
ADAPTIVE_WW_SITE_METHOD = local
ADAPTIVE_WW_DEPENDENCIES = host-pkgconf libnl openssl

MY_MAKE_OPTS = CXX="$(TARGET_CXX)" CC="$(TARGET_CC)" LD="$(TARGET_LD)" PKG_CONFIG="$(HOST_DIR)/usr/bin/pkg-config"

#
# BUILD
#
define ADAPTIVE_WW_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(MY_MAKE_OPTS) -C $(@D)/awm
	$(TARGET_MAKE_ENV) $(MAKE) $(MY_MAKE_OPTS) -C $(@D)/lpt
endef

#
#Install
#
define ADAPTIVE_WW_INSTALL_TARGET_CMDS
#Note: Do *NOT* install lpt on target.  This utility is for internal use only by FAEs to build
#      the txpower database used by adaptive ww.
	$(INSTALL) -D -m 755 $(@D)/awm/bin/adaptive_ww $(TARGET_DIR)/usr/bin/adaptive_ww
endef


#
# Uninstall
#
define ADAPTIVE_WW_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/bin/adaptive_ww
endef

$(eval $(generic-package))
