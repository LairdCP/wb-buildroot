#####################################################################
# Laird Industrial Gateway igconfd
#####################################################################

IGCONFD_VERSION = local
IGCONFD_SITE = package/lrd/externals/igconfd
IGCONFD_SITE_METHOD = local
IGCONFD_SETUP_TYPE = setuptools
IGCONFD_BUILD_OPTS = bdist_egg --exclude-source-files

ifeq ($(BR2_PACKAGE_PYTHON3),y)
IGCONFD_PYTHON_VERSION := 3.7
else
IGCONFD_PYTHON_VERSION := 2.7
endif


define IGCONFD_INSTALL_TARGET_FILES
        $(INSTALL) -D -m 755 $(@D)/dist/igconfd-1.0-py$(IGCONFD_PYTHON_VERSION).egg $(TARGET_DIR)/usr/bin/igconfd
        $(INSTALL) -D -m 644 package/lrd/igconfd/igconfd.service $(TARGET_DIR)/etc/systemd/system
        $(INSTALL) -D -m 644 package/lrd/igconfd/com.lairdtech.security.ConfigService.conf $(TARGET_DIR)/etc/dbus-1/system.d
        mkdir -p $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants
        ln -sf ../igconfd.service $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants
endef

IGCONFD_POST_INSTALL_TARGET_HOOKS += IGCONFD_INSTALL_TARGET_FILES

$(eval $(python-package))

