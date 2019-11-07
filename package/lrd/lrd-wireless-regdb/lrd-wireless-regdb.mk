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

LRD_WIRELESS_REGDB_DEPENDENCIES += host-python3 host-python-attrs

define LRD_WIRELESS_REGDB_BUILD_CMDS
     $(TARGET_MAKE_ENV) $(MAKE) NO_CERT=1 -C $(@D) all
endef

define LRD_WIRELESS_REGDB_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) DESTDIR=$(TARGET_DIR) NO_CERT=1 -C $(@D) install
endef

$(eval $(generic-package))
