#############################################################
#
# lrd-factory-reset-toolkit
#
#############################################################

LRD_FACTORY_RESET_TOOLKIT_DEPENDENCIES = lrd-network-manager

DEFAULT_TIMEZONE = $(call qstrip,$(BR2_TARGET_LOCALTIME))

define LRD_FACTORY_RESET_TOOLKIT_INSTALL_TARGET_CMDS
	rsync -rlpDWK package/lrd/lrd-factory-reset-toolkit/rootfs/ $(TARGET_DIR)/
	$(INSTALL) -d $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants
	ln -rsf $(TARGET_DIR)/usr/lib/systemd/system/factory-reset.service $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/factory-reset.service
endef
$(eval $(generic-package))
