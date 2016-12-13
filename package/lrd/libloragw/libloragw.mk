################################################################################
#
# libloragw
#
################################################################################

LIBLORAGW_VERSION = v4.1.0
LIBLORAGW_SITE = https://github.com/Lora-net/lora_gateway.git
LIBLORAGW_SITE_METHOD = git
LIBLORAGW_INSTALL_STAGING = YES

define LIBLORAGW_BUILD_CMDS
	CC="$(TARGET_CC)" $(MAKE) -C $(@D)
endef

define LIBLORAGW_INSTALL_STAGING_CMDS
	$(INSTALL) -d $(STAGING_DIR)/usr/lib/libloragw/inc/
	$(INSTALL) -D -m 755 $(@D)/libloragw/libloragw.a $(STAGING_DIR)/usr/lib/libloragw
	$(INSTALL) -D -m 755 $(@D)/libloragw/library.cfg $(STAGING_DIR)/usr/lib/libloragw
	$(INSTALL) -D -m 755 $(@D)/libloragw/inc/* $(STAGING_DIR)/usr/lib/libloragw/inc
endef

define LIBLORAGW_INSTALL_TARGET_CMDS
	$(INSTALL) -d $(TARGET_DIR)/opt/lora/
	$(INSTALL) -D -m 755 $(@D)/reset_lgw.sh $(TARGET_DIR)/usr/sbin/reset_lgw
endef

$(eval $(generic-package))

