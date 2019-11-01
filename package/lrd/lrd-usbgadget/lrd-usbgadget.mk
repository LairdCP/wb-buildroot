#############################################################
#
# Laird USB Ethernet Gadget Helper
#
#############################################################


define LRD_USBGADGET_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 package/lrd/lrd-usbgadget/usb-gadget.sh $(TARGET_DIR)/usr/bin/

	$(INSTALL) -d $(TARGET_DIR)/etc/NetworkManager/system-connections
	$(INSTALL) -m 0600 package/lrd/lrd-usbgadget/shared-usb0 $(TARGET_DIR)/etc/NetworkManager/system-connections
endef

ifeq ($(BR2_PACKAGE_LRD_USBGADGET_TYPE_RNDIS),y)
define LRD_USBGADGET_RNDIS_INSTALL_SYSTEMD
	ln -rsf $(TARGET_DIR)/usr/lib/systemd/system/usb-gadget@.service \
		$(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/usb-gadget@rndis.service
endef
endif

ifeq ($(BR2_PACKAGE_LRD_USBGADGET_TYPE_NCM),y)
define LRD_USBGADGET_NCM_INSTALL_SYSTEMD
	ln -rsf $(TARGET_DIR)/usr/lib/systemd/system/usb-gadget@.service \
		$(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/usb-gadget@ncm.service
endef
endif

define LRD_USBGADGET_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 package/lrd/lrd-usbgadget/usb-gadget@.service \
		$(TARGET_DIR)/usr/lib/systemd/system/usb-gadget@.service

	$(INSTALL) -d $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants

	$(LRD_USBGADGET_RNDIS_INSTALL_SYSTEMD)
	$(LRD_USBGADGET_NCM_INSTALL_SYSTEMD)
endef

$(eval $(generic-package))
