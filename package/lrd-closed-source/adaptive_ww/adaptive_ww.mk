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
ifeq ($(BR2_PACKAGE_ADAPTIVE_WW_LPT),y)
define LAIRD_AWM_LPT_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(MY_MAKE_OPTS) -C $(@D)/lpt
endef
endif

define ADAPTIVE_WW_BUILD_CMDS
	$(LAIRD_AWM_LPT_BUILD_CMDS)
	$(TARGET_MAKE_ENV) $(MAKE) $(MY_MAKE_OPTS) -C $(@D)/awm
endef

#
#Install
#
ifeq ($(BR2_PACKAGE_ADAPTVE_WW_REGPWRDB),y)
define AWM_REGPWRDB_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 644 $(@D)/lpt/db/regpwr.db $(TARGET_DIR)/lib/firmware/
endef
endif

ifeq ($(BR2_LRD_DEVEL_BUILD),y)
define AWM_STARTUP_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0644 -D $(@D)/awm/awm.service $(TARGET_DIR)/usr/lib/systemd/system/awm.service
	$(INSTALL) -m 0755 -D $(@D)/awm/S30adaptive-ww $(TARGET_DIR)/etc/init.d/S30adaptive-ww
endef
endif

define AWM_ADAPTIVE_WW_INSTALL_TARGET_CMDS
#Note: Do *NOT* install lpt on target.  This utility is for internal use only by FAEs to build
#      the txpower database used by adaptive ww.
	$(INSTALL) -D -m 755 $(@D)/awm/bin/adaptive_ww $(TARGET_DIR)/usr/bin/adaptive_ww
endef

define ADAPTIVE_WW_INSTALL_TARGET_CMDS
	$(AWM_ADAPTIVE_WW_INSTALL_TARGET_CMDS)
	$(AWM_REGPWRDB_INSTALL_TARGET_CMDS)
	$(AWM_STARTUP_INSTALL_TARGET_CMDS)
endef

define ADAPTIVE_WW_INSTALL_INIT_SYSTEMD
	$(INSTALL) -m 0644 -D $(@D)/awm/awm.service \
		$(TARGET_DIR)/usr/lib/systemd/system/awm.service
	$(INSTALL) -d $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants
	ln -rsf $(TARGET_DIR)/usr/lib/systemd/system/awm.service \
		$(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/awm.service
endef

define ADAPTIVE_WW_INSTALL_INIT_SYSV
	$(INSTALL) -m 0755 -D $(@D)/awm/S30adaptive-ww $(TARGET_DIR)/etc/init.d/S30adaptive-ww
endef

#
# Uninstall
#
define ADAPTIVE_WW_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/bin/adaptive_ww
	rm -f $(TARGET_DIR)/lib/firmware/regpwr.db
endef

$(eval $(generic-package))
