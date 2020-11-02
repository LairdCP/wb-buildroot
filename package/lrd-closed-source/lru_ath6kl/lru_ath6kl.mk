#############################################################
#
# lru tools
#
#############################################################
LRU_ATH6KL_VERSION = local
LRU_ATH6KL_SITE    = package/lrd-closed-source/externals/lru_ath6kl
LRU_ATH6KL_SITE_METHOD = local
LRU_ATH6KL_DEPENDENCIES = libnl host-pkgconf libedit

ifeq ($(BR2_PACKAGE_LRU_ATH6KL_WB50N_SUPPORT),y)
LRU_ATH6KL_SUFFIX = 50
else
LRU_ATH6KL_SUFFIX = 45
endif

MY_MAKE_OPTS = CXX="$(TARGET_CXX)" CC="$(TARGET_CC)" AR=$(TARGET_AR) LD="$(TARGET_LD)" PKG_CONFIG="$(HOST_DIR)/usr/bin/pkg-config"

#
# BUILD
#
define LRU_ATH6KL_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MY_MAKE_OPTS) $(MAKE)  -C $(@D)/Proprietary_tools/libtcmd
	$(TARGET_MAKE_ENV) $(MY_MAKE_OPTS) $(MAKE)  -C $(@D)/Proprietary_tools/lru  wb$(LRU_ATH6KL_SUFFIX)
endef

#
#Install
#
define LRU_ATH6KL_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/Proprietary_tools/lru/lru_$(LRU_ATH6KL_SUFFIX) $(TARGET_DIR)/usr/bin/lru
endef


$(eval $(generic-package))
