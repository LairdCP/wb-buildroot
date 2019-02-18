#############################################################
#
# Laird Auto Mount Helper
#
#############################################################

define LRD_AUTOMOUNT_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 package/lrd/lrd-automount/usb-mount.sh $(TARGET_DIR)/usr/bin/
endef

ifeq ($(BR2_PACKAGE_LRD_AUTOMOUNT_USB),y)
define LRD_AUTOMOUNT_INSTALL_USB_INIT_SYSTEMD
	$(INSTALL) -m 0755 package/lrd/lrd-automount/90-usbmount.rules $(TARGET_DIR)/etc/udev/rules.d/
endef
endif

ifeq ($(BR2_PACKAGE_LRD_AUTOMOUNT_MMC),y)
define LRD_AUTOMOUNT_INSTALL_MMC_INIT_SYSTEMD
	$(INSTALL) -m 0755 package/lrd/lrd-automount/91-mmcmount.rules $(TARGET_DIR)/etc/udev/rules.d/
endef
endif

define LRD_AUTOMOUNT_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 package/lrd/lrd-automount/usb-mount@.service \
		$(TARGET_DIR)/usr/lib/systemd/system/usb-mount@.service
	$(LRD_AUTOMOUNT_INSTALL_USB_INIT_SYSTEMD)
	$(LRD_AUTOMOUNT_INSTALL_MMC_INIT_SYSTEMD)
endef

$(eval $(generic-package))
