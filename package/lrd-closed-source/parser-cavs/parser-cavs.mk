#############################################################
#
#  KCAPI CAVS
#
#############################################################

PARSER_CAVS_VERSION = local
PARSER_CAVS_SITE    = package/lrd-closed-source/externals/cavs_api/parser
PARSER_CAVS_SITE_METHOD = local
PARSER_CAVS_DEPENDENCIES = host-pkgconf libgcrypt libgpg-error openssl keyutils

PARSER_CAVS_MAKE_ENV = CC=$(TARGET_CC) PKG_CONFIG=$(PKG_CONFIG_HOST_BINARY) \
	INCLUDE_DIRS="$(STAGING_DIR)/usr/include"

define PARSER_CAVS_BUILD_CMDS
	rm -rf $(@D)/*.o
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) kcapi $(PARSER_CAVS_MAKE_ENV)
	rm -rf $(@D)/*.o
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) openssl $(PARSER_CAVS_MAKE_ENV)
endef

define PARSER_CAVS_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/cavs_driver_kcapi $(TARGET_DIR)/usr/bin/
	$(INSTALL) -D -m 755 $(@D)/cavs_driver_openssl $(TARGET_DIR)/usr/bin/
	$(INSTALL) -D -m 755 $(@D)/cavs_exec_kcapi.sh $(TARGET_DIR)/usr/bin/
	$(INSTALL) -D -m 755 $(@D)/cavs_exec_openssl.sh $(TARGET_DIR)/usr/bin/
endef

$(eval $(generic-package))
