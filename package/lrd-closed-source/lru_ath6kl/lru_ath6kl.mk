#############################################################
#
# lru tools
#
#############################################################

LRU_ATH6KL_VERSION = local
LRU_ATH6KL_SITE    = package/lrd-closed-source/externals/lru_ath6kl
LRU_ATH6KL_SITE_METHOD = local
LRU_ATH6KL_DEPENDENCIES = libnl host-pkgconf readline
ifeq ($(BR2_PACKAGE_LRU_ATH6KL_WB50N_SUPPORT),y)
LRU_ATH6KL_CHIP_FLAGS = -DSUPPORT_6004
LRU_ATH6KL_SUFFIX = 50
else
LRU_ATH6KL_SUFFIX = 45
endif


ifeq ($(BR2_PACKAGE_LRU_ATH6KL_TEST_MODE),y)
LRU_ATH6KL_TEST_FLAG = -DLRU_TESTMODE
endif


define LRU_ATH6KL_BUILD_CMDS
	$(MAKE) -C $(@D)/Proprietary_tools/libtcmd \
            CC="$(TARGET_CC)" AR="$(TARGET_AR)" \
            PKGCONFIG="$(HOST_DIR)/usr/bin/pkg-config" TEST_MODE_SUPPORT="$(LRU_ATH6KL_TEST_FLAG)"
	$(MAKE) -C $(@D)/Proprietary_tools/lru_$(LRU_ATH6KL_SUFFIX) \
               CC="$(TARGET_CC)" AR="$(TARGET_AR)" \
               PKGCONFIG="$(HOST_DIR)/usr/bin/pkg-config" TEST_MODE_SUPPORT="$(LRU_ATH6KL_TEST_FLAG)"
endef

define LRU_ATH6KL_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/Proprietary_tools/lru_$(LRU_ATH6KL_SUFFIX)/lru_$(LRU_ATH6KL_SUFFIX) $(TARGET_DIR)/usr/bin/lru
endef

$(eval $(generic-package))
