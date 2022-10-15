#############################################################
#
# 60 Series Adaptive World Mode Daemon
#
#############################################################
ADAPTIVE_WW_VERSION = local
ADAPTIVE_WW_SITE = package/lrd-closed-source/externals/adaptive_ww
ADAPTIVE_WW_SITE_METHOD = local
ADAPTIVE_WW_DEPENDENCIES = host-pkgconf libnl libtomcrypt libconfig

#
# BUILD
#
ifeq ($(BR2_PACKAGE_ADAPTIVE_WW_LPT),y)
define LAIRD_AWM_LPT_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)/lpt
endef
endif

define ADAPTIVE_WW_BUILD_CMDS
	$(LAIRD_AWM_LPT_BUILD_CMDS)
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)/awm
endef

#
#Install
#
ifeq ($(BR2_INIT_NONE),y)
define AWM_STARTUP_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0644 -D $(@D)/awm/adaptive_ww.service $(TARGET_DIR)/usr/lib/systemd/system/adaptive_ww.service
	$(INSTALL) -m 0755 -D $(@D)/awm/adaptive_ww $(TARGET_DIR)/etc/init.d/adaptive_ww
endef
endif

define AWM_ADAPTIVE_WW_INSTALL_TARGET_CMDS
#Note: Do *NOT* install lpt on target.  This utility is for internal use only by FAEs to build
#      the txpower database used by adaptive ww.
	$(INSTALL) -D -m 0755 $(@D)/awm/bin/adaptive_ww $(TARGET_DIR)/usr/bin/adaptive_ww
endef

define ADAPTIVE_WW_INSTALL_TARGET_CMDS
	$(AWM_ADAPTIVE_WW_INSTALL_TARGET_CMDS)
	$(AWM_STARTUP_INSTALL_TARGET_CMDS)
	$(AWM_CONFIG_INSTALL_TARGET_CMDS)
endef

ifeq ($(BR2_PACKAGE_ADAPTIVE_WW_MODE_LITE),y)
AWM_PARAM += -M lite
endif

ifeq ($(BR2_PACKAGE_ADAPTIVE_WW_INTF_AP),y)
AWM_PARAM += -F AP
else ifeq ($(BR2_PACKAGE_ADAPTIVE_WW_INTF_NONE),y)
AWM_PARAM += -F NONE
endif

ifneq ($(BR2_PACKAGE_ADAPTIVE_WW_CFG_FILE),"")
AWM_PARAM += -C $(BR2_PACKAGE_ADAPTIVE_WW_CFG_FILE)
endif

define AWM_CONFIG_INSTALL_TARGET_CMDS
	mkdir -p "$(TARGET_DIR)/etc/default"
	echo "AWM_ARGS=$(AWM_PARAM)" > $(TARGET_DIR)/etc/default/adaptive_ww
endef

define ADAPTIVE_WW_INSTALL_INIT_SYSTEMD
	$(INSTALL) -m 0644 -D $(@D)/awm/adaptive_ww.service \
		$(TARGET_DIR)/usr/lib/systemd/system/adaptive_ww.service
endef

define ADAPTIVE_WW_INSTALL_INIT_SYSV
	$(INSTALL) -m 0755 -D $(@D)/awm/adaptive_ww $(TARGET_DIR)/etc/init.d/S30adaptive_ww
endef

#
# Uninstall
#
define ADAPTIVE_WW_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/bin/adaptive_ww
endef

$(eval $(generic-package))
