#############################################################
#
# Laird Auto Mount Helper
#
#############################################################

define LRD_AUTOMOUNT_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 package/lrd/lrd-automount/usb-mount.sh \
		$(TARGET_DIR)/usr/bin/usb-mount.sh

	$(INSTALL) -d $(TARGET_DIR)/etc/default
	echo "MOUNT_USER_MMC=$(BR2_PACKAGE_LRD_AUTOMOUNT_MMC_USER)" \
		>$(TARGET_DIR)/etc/default/usb-mount
	echo "MOUNT_USER_USB=$(BR2_PACKAGE_LRD_AUTOMOUNT_USB_USER)" \
		>>$(TARGET_DIR)/etc/default/usb-mount
endef

ifeq ($(BR2_PACKAGE_LRD_AUTOMOUNT_USB),y)
define LRD_AUTOMOUNT_INSTALL_USB_INIT_SYSTEMD
	$(INSTALL) -D -m 644 package/lrd/lrd-automount/90-usbmount.rules \
		$(TARGET_DIR)/etc/udev/rules.d/90-usbmount.rules
endef

define LRD_AUTOMOUNT_INSTALL_USB_INIT_SYSV
	$(INSTALL) -D -m 644 package/lrd/lrd-automount/90-usbmount-sysv.rules \
		$(TARGET_DIR)/etc/udev/rules.d/90-usbmount.rules
endef
endif

ifeq ($(BR2_PACKAGE_LRD_AUTOMOUNT_MMC),y)
define LRD_AUTOMOUNT_INSTALL_MMC_INIT_SYSTEMD
	$(INSTALL) -D -m 644 package/lrd/lrd-automount/91-mmcmount.rules \
		$(TARGET_DIR)/etc/udev/rules.d/91-mmcmount.rules
endef

define LRD_AUTOMOUNT_INSTALL_MMC_INIT_SYSV
	$(INSTALL) -D -m 644 package/lrd/lrd-automount/91-mmcmount-sysv.rules \
		$(TARGET_DIR)/etc/udev/rules.d/91-mmcmount.rules
endef
endif

define LRD_AUTOMOUNT_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 package/lrd/lrd-automount/usb-mount@.service \
		$(TARGET_DIR)/usr/lib/systemd/system/usb-mount@.service

	$(LRD_AUTOMOUNT_INSTALL_USB_INIT_SYSTEMD)
	$(LRD_AUTOMOUNT_INSTALL_MMC_INIT_SYSTEMD)
endef

define LRD_AUTOMOUNT_INSTALL_INIT_SYSV
	$(LRD_AUTOMOUNT_INSTALL_USB_INIT_SYSV)
	$(LRD_AUTOMOUNT_INSTALL_MMC_INIT_SYSV)
endef

$(eval $(generic-package))
