################################################################################
#
# libloragw
#
################################################################################

LIBLORAGW_VERSION = v4.1.3
LIBLORAGW_SITE = https://github.com/Lora-net/lora_gateway.git
LIBLORAGW_SITE_METHOD = git
LIBLORAGW_INSTALL_STAGING = YES

define LIBLORAGW_BUILD_CMDS
	CC="$(TARGET_CC)" $(MAKE) -C $(@D)
endef

define LIBLORAGW_INSTALL_STAGING_CMDS
	$(INSTALL) -D -m 644 -t $(STAGING_DIR)/usr/lib/libloragw \
		$(@D)/libloragw/libloragw.a $(@D)/libloragw/library.cfg
	$(INSTALL) -D -m 644 -t $(STAGING_DIR)/usr/lib/libloragw/inc $(@D)/libloragw/inc/*
endef

define LIBLORAGW_INSTALL_TARGET_CMDS
	$(INSTALL) -d $(TARGET_DIR)/opt/lora/
	$(INSTALL) -D -m 755 $(@D)/reset_lgw.sh $(TARGET_DIR)/usr/sbin/reset_lgw
endef

$(eval $(generic-package))

