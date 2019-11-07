##########################################################################
# Sentrius IG60 lrd_bt_utils
##########################################################################

LRD_BT_UTILS_VERSION = local
LRD_BT_UTILS_SITE = package/lrd/externals/lrd-bt-utils
LRD_BT_UTILS_SITE_METHOD = local


define LRD_BT_UTILS_INSTALL_TARGET_FILES
	$(INSTALL) -D -m 755 $(LRD_BT_UTILS_SITE)/*.py $(TARGET_DIR)/usr/bin/
	$(INSTALL) -D -m 755 $(LRD_BT_UTILS_SITE)/btpa_firmware_loader/*.py $(TARGET_DIR)/usr/bin
endef

LRD_BT_UTILS_POST_INSTALL_TARGET_HOOKS += LRD_BT_UTILS_INSTALL_TARGET_FILES

$(eval $(generic-package))

