#############################################################
#
# PHP SDK
#
#############################################################

PHP_SDK_VERSION = local
PHP_SDK_SITE = package/lrd/externals/php_sdk
PHP_SDK_SITE_METHOD = local
PHP_SDK_LICENSE = ICS

PHP_SDK_DEPENDENCIES = php host-swig

ifeq ($(BR2_PACKAGE_WB_LEGACY_SUMMIT_SUPPLICANT_BINARIES),y)
PHP_SDK_DEPENDENCIES += wb-legacy-summit-supplicant-binaries
else
PHP_SDK_DEPENDENCIES += sdcsdk
endif

PHP_SDK_MAKE_ENV = CC="$(TARGET_CC)" \
			CXX="$(TARGET_CXX)" \
			ARCH="$(KERNEL_ARCH)" \
			CFLAGS="$(TARGET_CFLAGS)" \
			INCLUDES="-I$(STAGING_DIR)/usr/include/php \
				-I$(STAGING_DIR)/usr/include/php/Zend \
				-I$(STAGING_DIR)/usr/include/php/main \
				-I$(STAGING_DIR)/usr/include/php/TSRM"

PHP_SDK_TARGET_DIR = $(TARGET_DIR)

define PHP_SDK_BUILD_CMDS
	$(PHP_SDK_MAKE_ENV) $(MAKE) -j 1 -C $(@D)
endef

define PHP_SDK_INSTALL_STAGING_CMDS
endef

ifeq ($(BR2_PACKAGE_PHP_SDK_TEST),y)
	INSTALL_TEST = $(INSTALL) -D -m 755 $(@D)/examples/lrd_sdk_GetVersion.php $(TARGET_DIR)/var/www/docs/examples/lrd_sdk_GetVersion.php
else
	INSTALL_TEST =
endif

define PHP_SDK_INSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/lib/lrd_php_sdk.so*
	$(INSTALL) -D -m 755 $(@D)/lrd_php_sdk.so* $(TARGET_DIR)/usr/lib/
	cd  $(TARGET_DIR)/usr/lib/ && ln -s lrd_php_sdk.so* lrd_php_sdk.so
	$(INSTALL) -D -m 755 $(@D)/lrd_php_sdk.php $(TARGET_DIR)/var/www/docs/lrd_php_sdk.php
	$(INSTALL_TEST)
endef

define PHP_SDK_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/lib/lrd_php_sdk.so*
	rm -f $(TARGET_DIR)/var/www/docs/lrd_php_sdk.php
endef

$(eval $(generic-package))
