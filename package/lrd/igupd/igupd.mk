#####################################################################
# Laird Industrial Gateway igupd
#####################################################################

IGUPD_VERSION = local
IGUPD_SITE = package/lrd/externals/igupd
IGUPD_SITE_METHOD = local
IGUPD_SETUP_TYPE = setuptools
IGUPD_BUILD_OPTS = bdist_egg --exclude-source-files

define IGUPD_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/dist/igupd-1.0-py$(PYTHON3_VERSION_MAJOR).egg $(TARGET_DIR)/usr/bin/igupd
	$(INSTALL) -D -t $(TARGET_DIR)/etc/dbus-1/system.d -m 644 package/lrd/igupd/com.lairdtech.security.UpdateService.conf
	$(INSTALL) -D -t $(TARGET_DIR)/etc -m 644 package/lrd/igupd/secupdate.cfg
endef

define IGUPD_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 -t $(TARGET_DIR)/etc/systemd/system package/lrd/igupd/igupd.service
endef

$(eval $(python-package))
