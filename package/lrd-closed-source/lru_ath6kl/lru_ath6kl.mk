#############################################################
#
# lru tools
#
#############################################################
LRU_ATH6KL_VERSION = local
LRU_ATH6KL_SITE    = package/lrd-closed-source/externals/lru_ath6kl
LRU_ATH6KL_SITE_METHOD = local
LRU_ATH6KL_DEPENDENCIES = libnl host-pkgconf libedit

MY_MAKE_OPTS = CXX="$(TARGET_CXX)" CC="$(TARGET_CC)" AR=$(TARGET_AR) LD="$(TARGET_LD)" PKG_CONFIG="$(HOST_DIR)/usr/bin/pkg-config"

ifeq ($(BR2_PACKAGE_LRU_ATH6KL_WB50N_SUPPORT),y)
LRU_ATH6KL_SUFFIX = 50
else
LRU_ATH6KL_SUFFIX = 45
endif

ifeq ($(BR2_PACKAGE_LRU_ATH6KL_TEST_MODE),y)
MY_MAKE_OPTS += LRU_ATH6KL_TEST_MODE="-DLRU_TESTMODE"
endif

#
# BUILD
#
define LRU_ATH6KL_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(MY_MAKE_OPTS) -C $(@D)/Proprietary_tools/libtcmd
	$(TARGET_MAKE_ENV) $(MAKE) $(MY_MAKE_OPTS) -C $(@D)/Proprietary_tools/lru_$(LRU_ATH6KL_SUFFIX)
endef

#
#Install
#
define LRU_ATH6KL_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/Proprietary_tools/lru_$(LRU_ATH6KL_SUFFIX)/lru_$(LRU_ATH6KL_SUFFIX) $(TARGET_DIR)/usr/bin/lru
endef


$(eval $(generic-package))
