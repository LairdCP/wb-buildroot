#############################################################
#
#  OpenSSL FIPS Testing
#
#############################################################

OPENSSL_TESTING_VERSION = local
OPENSSL_TESTING_SITE    = package/lrd-closed-source/externals/cavs_api/openssl_testing
OPENSSL_TESTING_SITE_METHOD = local
OPENSSL_TESTING_DEPENDENCIES = host-pkgconf openssl

OPENSSL_TESTING_MAKE_ENV = CC=$(TARGET_CC) \
	PKG_CONFIG=$(PKG_CONFIG_HOST_BINARY)

define OPENSSL_TESTING_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) $(OPENSSL_TESTING_MAKE_ENV)
endef

define OPENSSL_TESTING_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/openssl_testing $(TARGET_DIR)/usr/bin/
endef

$(eval $(generic-package))
