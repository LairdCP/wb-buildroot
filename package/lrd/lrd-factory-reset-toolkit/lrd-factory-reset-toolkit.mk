#############################################################
#
# lrd-factory-reset-toolkit
#
#############################################################

LRD_FACTORY_RESET_TOOLKIT_DEPENDENCIES = lrd-network-manager

define FACTORY_RESET_POST_INSTALL_TARGET_HOOK
	rsync -rlptDWK package/lrd/lrd-factory-reset-toolkit/rootfs/ $(TARGET_DIR)/
endef

LRD_FACTORY_RESET_TOOLKIT_POST_INSTALL_TARGET_HOOKS += FACTORY_RESET_POST_INSTALL_TARGET_HOOK

$(eval $(generic-package))
