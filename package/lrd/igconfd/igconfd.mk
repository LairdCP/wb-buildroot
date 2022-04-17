#####################################################################
# Laird Industrial Gateway igconfd
#####################################################################

IGCONFD_VERSION = local
IGCONFD_SITE = package/lrd/externals/igconfd
IGCONFD_SITE_METHOD = local
IGCONFD_SETUP_TYPE = setuptools

define IGCONFD_INSTALL_INIT_SYSTEMD
        $(INSTALL) -D -m 644 -t $(TARGET_DIR)/etc/systemd/system \
		    package/lrd/igconfd/igconfd.service
        $(INSTALL) -D -m 644 -t $(TARGET_DIR)/etc/dbus-1/system.d \
		    package/lrd/igconfd/com.lairdtech.security.ConfigService.conf
        $(INSTALL) -d $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants
        ln -rsf $(TARGET_DIR)/etc/systemd/system/igconfd.service $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/igconfd.service
endef

$(eval $(python-package))

