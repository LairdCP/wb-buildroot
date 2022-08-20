#############################################################
#
#  PARSER ACVP
#
#############################################################

PARSER_ACVP_VERSION = local
PARSER_ACVP_SITE    = package/lrd-closed-source/externals/cavs_api/acvpparser
PARSER_ACVP_SITE_METHOD = local
PARSER_ACVP_DEPENDENCIES = libgcrypt libgpg-error openssl keyutils

PARSER_ACVP_MAKE_ENV = \
	$(TARGET_MAKE_ENV) \
	CFLAGS="$(TARGET_CFLAGS) -I$(STAGING_DIR)/usr/include" \

PARSER_ACVP_MAKE_ENV2 = \
	CC="$(TARGET_CC)" \
	OS=buildroot \
	UNAME_S=Linux

define PARSER_ACVP_BUILD_CMDS
	$(MAKE) -C $(@D) clean
	$(PARSER_ACVP_MAKE_ENV) $(MAKE) -C $(@D) kcapi $(PARSER_ACVP_MAKE_ENV2)
	$(MAKE) -C $(@D) clean
	$(PARSER_ACVP_MAKE_ENV) $(MAKE) -C $(@D) openssl3 $(PARSER_ACVP_MAKE_ENV2)
endef

define PARSER_ACVP_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/acvp-parser-kcapi $(TARGET_DIR)/usr/bin/
	$(INSTALL) -D -m 755 $(@D)/acvp-parser-openssl3 $(TARGET_DIR)/usr/bin/
	$(INSTALL) -D -m 755 $(@D)/helper-laird/exec_laird_kcapi.sh  $(TARGET_DIR)/usr/bin/
	$(INSTALL) -D -m 755 $(@D)/helper-laird/exec_laird_summitssl.sh  $(TARGET_DIR)/usr/bin/
	$(INSTALL) -D -m 755 $(@D)/helper-laird/exec_laird_lib.sh  $(TARGET_DIR)/usr/bin/
endef

$(eval $(generic-package))
