#############################################################
#
# Laird Connectivity USB Ethernet Gadget Helper
#
#############################################################

ifneq ($(BR2_PACKAGE_LRD_NETWORK_MANAGER)$(BR2_PACKAGE_NETWORK_MANAGER),)
define LRD_USBGADGET_INSTALL_NM
	$(INSTALL) -D -m 0600 -t $(TARGET_DIR)/etc/NetworkManager/system-connections/ \
		package/lrd/lrd-usbgadget/shared-usb0.nmconnection 
endef
endif

define LRD_USBGADGET_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 -t $(TARGET_DIR)/usr/bin/ \
		package/lrd/lrd-usbgadget/usb-gadget.sh

	$(LRD_USBGADGET_INSTALL_NM)
endef

define LRD_USBGADGET_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 package/lrd/lrd-usbgadget/usb-gadget@.service \
		$(TARGET_DIR)/usr/lib/systemd/system/usb-gadget@.service

	$(INSTALL) -d $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants
	ln -rsf $(TARGET_DIR)/usr/lib/systemd/system/usb-gadget@.service \
		$(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/usb-gadget@$(call qstrip,$(BR2_PACKAGE_LRD_USBGADGET_TYPE_STRING)).service
endef

define LRD_USBGADGET_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 -t $(TARGET_DIR)/etc/init.d/ \
		package/lrd/lrd-usbgadget/S43usb-gadget

	sed -i "s/proto=.*/proto=$(BR2_PACKAGE_LRD_USBGADGET_TYPE_STRING)/" \
		$(TARGET_DIR)/etc/init.d/S43usb-gadget
endef

$(eval $(generic-package))
