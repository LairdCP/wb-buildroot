#############################################################
#
# Laird Legacy Software
#
#############################################################

define LRD_LEGACY_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/etc/dhcp/
	$(INSTALL) -D -m 755 package/lrd/externals/lrd-legacy/rootfs-additions/etc/dhcp/* $(TARGET_DIR)/etc/dhcp/
	mkdir -p $(TARGET_DIR)/etc/init.d/
	$(INSTALL) -D -m 755 package/lrd/externals/lrd-legacy/rootfs-additions/etc/init.d/S09network $(TARGET_DIR)/etc/init.d/
	mkdir -p $(TARGET_DIR)/etc/network/
	$(INSTALL) -D -m 755 package/lrd/externals/lrd-legacy/rootfs-additions/etc/network/* $(TARGET_DIR)/etc/network/
	mkdir -p $(TARGET_DIR)/usr/sbin/
	$(INSTALL) -D -m 755 package/lrd/externals/lrd-legacy/rootfs-additions/usr/sbin/* $(TARGET_DIR)/usr/sbin/
	mkdir -p $(TARGET_DIR)/sbin/
	$(INSTALL) -D -m 755 package/lrd/externals/lrd-legacy/rootfs-additions/sbin/* $(TARGET_DIR)/sbin/
endef

$(eval $(generic-package))
