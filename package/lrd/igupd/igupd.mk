#####################################################################
# Laird Industrial Gateway igupd
#####################################################################

IGUPD_VERSION = local
IGUPD_SITE = package/lrd/externals/igupd
IGUPD_SITE_METHOD = local
IGUPD_SETUP_TYPE = setuptools
IGUPD_BUILD_OPTS = bdist_egg --exclude-source-files

ifeq ($(BR2_PACKAGE_PYTHON3),y)
IGUPD_PYTHON_VERSION := 3.8
else
IGUPD_PYTHON_VERSION := 2.7
endif

define IGUPD_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/dist/igupd-1.0-py$(IGUPD_PYTHON_VERSION).egg $(TARGET_DIR)/usr/bin/igupd
	$(INSTALL) -D -t $(TARGET_DIR)/etc/dbus-1/system.d -m 644 package/lrd/igupd/com.lairdtech.security.UpdateService.conf
	$(INSTALL) -D -t $(TARGET_DIR)/etc -m 644 package/lrd/igupd/secupdate.cfg
endef

define IGUPD_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 -t $(TARGET_DIR)/etc/systemd/system package/lrd/igupd/igupd.service
	$(INSTALL) -d $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants
	ln -rsf $(TARGET_DIR)/etc/systemd/system/igupd.service $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/igupd.service
endef

$(eval $(python-package))
