#############################################################
#
# laird Connectivity WiFi bridge
#
#############################################################

LRD_WIFI_BRIDGE_INTERFACE = $(call qstrip,$(BR2_PACKAGE_LRD_WIFI_BRIDGE_INTERFACE))

define LRD_WIFI_BRIDGE_INSTALL_TARGET_CMDS

	rm -rf $(TARGET_DIR)/etc/NetworkManager/system-connections

	$(INSTALL) -D -m 0600 $(LRD_WIFI_BRIDGE_PKGDIR)rootfs/etc/NetworkManager/system-connections/bridge-slave-eth0.nmconnection \
		$(TARGET_DIR)/etc/NetworkManager/system-connections/bridge-slave-$(LRD_WIFI_BRIDGE_INTERFACE).nmconnection
	$(INSTALL) -D -m 0600 $(LRD_WIFI_BRIDGE_PKGDIR)rootfs/etc/NetworkManager/system-connections/bridge-br0.nmconnection \
		$(TARGET_DIR)/etc/NetworkManager/system-connections/bridge-slave-br0.nmconnection
	$(INSTALL) -D -m 0600 $(LRD_WIFI_BRIDGE_PKGDIR)rootfs/etc/NetworkManager/system-connections/bridge-slave-wlan0.nmconnection \
		$(TARGET_DIR)/etc/NetworkManager/system-connections/bridge-slave-wlan0.nmconnection
	$(INSTALL) -D -m 0600 $(LRD_WIFI_BRIDGE_PKGDIR)rootfs/etc/NetworkManager/dispatcher.d/pre-down.d/bridge.dispatcher \
		$(TARGET_DIR)/etc/NetworkManager/dispatcher.d/pre-down.d/bridge.dispatcher
	$(INSTALL) -D -m 0600 $(LRD_WIFI_BRIDGE_PKGDIR)rootfs/etc/NetworkManager/dispatcher.d/pre-up.d/bridge.dispatcher \
		$(TARGET_DIR)/etc/NetworkManager/dispatcher.d/pre-up.d/bridge.dispatcher

	$(SED) 's/eth0/$(LRD_WIFI_BRIDGE_INTERFACE)/' \
		$(TARGET_DIR)/etc/NetworkManager/system-connections/bridge-slave-$(LRD_WIFI_BRIDGE_INTERFACE).nmconnection;
endef

$(eval $(generic-package))
