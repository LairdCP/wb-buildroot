#####################################################################
# Laird Industrial Gateway igupd
#####################################################################

IGUPD_VERSION = local
IGUPD_SITE = package/lrd/externals/igupd
IGUPD_SITE_METHOD = local
IGUPD_SETUP_TYPE = setuptools
IGUPD_BUILD_OPTS = bdist_egg --exclude-source-files

ifeq ($(BR2_PACKAGE_PYTHON3),y)
IGUPD_PYTHON_VERSION := 3.7
else
IGUPD_PYTHON_VERSION := 2.7
endif

define IGUPD_INSTALL_TARGET_FILES
	$(INSTALL) -D -m 755 $(@D)/dist/igupd-1.0-py$(IGUPD_PYTHON_VERSION).egg $(TARGET_DIR)/usr/bin/igupd
	$(INSTALL) -D -m 644 package/lrd/igupd/igupd.service $(TARGET_DIR)/etc/systemd/system
        $(INSTALL) -D -m 644 package/lrd/igupd/com.lairdtech.security.UpdateService.conf $(TARGET_DIR)/etc/dbus-1/system.d
	mkdir -p $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants
	ln -sf ../igupd.service $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants
        $(INSTALL) -D -m 644 package/lrd/igupd/secupdate.cfg $(TARGET_DIR)/etc/
endef

IGUPD_POST_INSTALL_TARGET_HOOKS += IGUPD_INSTALL_TARGET_FILES

$(eval $(python-package))
