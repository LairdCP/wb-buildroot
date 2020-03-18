##########################################################################
# Sentrius IG60 lrd_bt_utils
##########################################################################

LRD_BT_UTILS_VERSION = local
LRD_BT_UTILS_SITE = package/lrd/externals/lrd-bt-utils
LRD_BT_UTILS_SITE_METHOD = local

define LRD_BT_UTILS_INSTALL_TARGET_CMDS
	$(INSTALL) -D -t $(TARGET_DIR)/usr/bin -m 755 $(LRD_BT_UTILS_SITE)/*.py
	$(INSTALL) -D -t $(TARGET_DIR)/usr/bin -m 755 $(LRD_BT_UTILS_SITE)/btpa_firmware_loader/*.py
endef

$(eval $(generic-package))

