#############################################################
#
# lrd-factory-reset-toolkit
#
#############################################################

LRD_FACTORY_RESET_TOOLKIT_DEPENDENCIES = lrd-network-manager

DEFAULT_TIMEZONE = $(call qstrip,$(BR2_TARGET_LOCALTIME))

define LRD_FACTORY_RESET_TOOLKIT_INSTALL_TARGET_CMDS
	rsync -rlpDWK $(LRD_FACTORY_RESET_TOOLKIT_PKGDIR)/rootfs/ $(TARGET_DIR)/
	sed -i -e '/^FACTORY_SETTING_DEFAULT_ZONE=/c FACTORY_SETTING_DEFAULT_ZONE=/usr/share/zoneinfo/${DEFAULT_TIMEZONE}' $(TARGET_DIR)/usr/sbin/do_factory_reset.sh
endef

$(eval $(generic-package))
