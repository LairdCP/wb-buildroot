#############################################################
#
# lrd-factory-reset-toolkit
#
#############################################################

LRD_FACTORY_RESET_TOOLKIT_DEPENDENCIES = lrd-network-manager

define FACTORY_RESET_POST_INSTALL_TARGET_CMDS
	rsync -rlptDWK package/lrd/lrd-factory-reset-toolkit/rootfs/ $(TARGET_DIR)/
endef

$(eval $(generic-package))
