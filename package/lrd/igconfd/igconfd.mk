#####################################################################
# Laird Industrial Gateway igconfd
#####################################################################

IGCONFD_VERSION = local
IGCONFD_SITE = package/lrd/externals/igconfd
IGCONFD_SITE_METHOD = local
IGCONFD_SETUP_TYPE = setuptools
IGCONFD_BUILD_OPTS = bdist_egg --exclude-source-files

ifeq ($(BR2_PACKAGE_PYTHON3),y)
IGCONFD_PYTHON_VERSION := 3.8
else
IGCONFD_PYTHON_VERSION := 2.7
endif

define IGCONFD_INSTALL_TARGET_CMDS
        $(INSTALL) -D -m 755 $(@D)/dist/igconfd-1.0-py$(IGCONFD_PYTHON_VERSION).egg $(TARGET_DIR)/usr/bin/igconfd
endef

define IGCONFD_INSTALL_INIT_SYSTEMD
        $(INSTALL) -D -m 644 -t $(TARGET_DIR)/etc/systemd/system \
		package/lrd/igconfd/igconfd.service
        $(INSTALL) -D -m 644 -t $(TARGET_DIR)/etc/dbus-1/system.d \
		package/lrd/igconfd/com.lairdtech.security.ConfigService.conf
        $(INSTALL) -d $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants
        ln -rsf $(TARGET_DIR)/etc/systemd/system/igconfd.service $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/igconfd.service
endef

$(eval $(python-package))

