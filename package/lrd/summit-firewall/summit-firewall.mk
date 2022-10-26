#############################################################
#
# Summit Basic Wi-Fi NAT/Firewall
#
#############################################################

SUMMIT_FIREWALL_INTERFACE = $(call qstrip,$(BR2_PACKAGE_SUMMIT_FIREWALL_INTERFACE))
SUMMIT_FIREWALL_IPV4 = $(call qstrip,$(BR2_PACKAGE_SUMMIT_FIREWALL_INTERFACE_IPV4))

define SUMMIT_FIREWALL_INSTALL_TARGET_CMDS
	rsync -rlpDWK --no-perms --exclude=.empty  $(SUMMIT_FIREWALL_PKGDIR)/rootfs-additions/ $(TARGET_DIR)/

	mv -f $(TARGET_DIR)/usr/lib/NetworkManager/system-connections/internal-@@INTERFACE@@.nmconnection \
		$(TARGET_DIR)/usr/lib/NetworkManager/system-connections/internal-$(SUMMIT_FIREWALL_INTERFACE).nmconnection
	chmod 0600 $(TARGET_DIR)/usr/lib/NetworkManager/system-connections/internal-$(SUMMIT_FIREWALL_INTERFACE).nmconnection

	$(SED) 's,@@INTERFACE@@,$(SUMMIT_FIREWALL_INTERFACE),g;s,@@IPV4@@,$(SUMMIT_FIREWALL_IPV4),g' \
		$(TARGET_DIR)/etc/wifi-nat.conf $(TARGET_DIR)/etc/wifi6-nat.conf \
		$(TARGET_DIR)/usr/lib/NetworkManager/system-connections/internal-$(SUMMIT_FIREWALL_INTERFACE).nmconnection
endef

define SUMMIT_FIREWALL_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 $(SUMMIT_FIREWALL_PKGDIR)/wifi-nat.service \
		$(TARGET_DIR)/usr/lib/systemd/system/wifi-nat.service
endef

$(eval $(generic-package))
