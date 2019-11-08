################################################################################
#
# lrd-wireless-regdb
#
################################################################################

LRD_WIRELESS_REGDB_VERSION = local
LRD_WIRELESS_REGDB_SITE = package/lrd/externals/lrd-wireless-regdb
LRD_WIRELESS_REGDB_SITE_METHOD = local
LRD_WIRELESS_REGDB_LICENSE = ISC
LRD_WIRELESS_REGDB_LICENSE_FILES = LICENSE

ifeq ($(BR2_PACKAGE_PYTHON),y)
LRD_WIRELESS_REGDB_DEPENDENCIES = host-python host-python-attrs
LRD_WIRELESS_REGDB_PYTHON = python
else ifeq ($(BR2_PACKAGE_PYTHON3),y)
LRD_WIRELESS_REGDB_DEPENDENCIES = host-python3 host-python-attrs
LRD_WIRELESS_REGDB_PYTHON = python3
else
LRD_WIRELESS_REGDB_DEPENDENCIES = host-python host-python-attrs
LRD_WIRELESS_REGDB_PYTHON = python
endif

define LRD_WIRELESS_REGDB_BUILD_CMDS
     $(TARGET_MAKE_ENV) $(MAKE) PYTHON=$(LRD_WIRELESS_REGDB_PYTHON) NO_CERT=1 -C $(@D) all
endef

define LRD_WIRELESS_REGDB_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) DESTDIR=$(TARGET_DIR) NO_CERT=1 -C $(@D) install
endef

$(eval $(generic-package))
