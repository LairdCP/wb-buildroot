#############################################################
#
# Laird smartBASIC apps for the WB
#
#############################################################

WB_SMARTBASIC_APPS_VERSION = local
WB_SMARTBASIC_APPS_SITE = package/lrd/externals/wb_smartBASIC_apps
WB_SMARTBASIC_APPS_SITE_METHOD = local

define WB_SMARTBASIC_APPS_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/'$autorun$.SPPBridge.Socket.wb.sb' $(TARGET_DIR)/etc/summit/'$autorun$.SPPBridge.Socket.wb.sb'
endef

define WB_SMARTBASIC_APPS_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/etc/summit/'$autorun$.SPPBridge.Socket.wb.sb'
endef

$(eval $(generic-package))
