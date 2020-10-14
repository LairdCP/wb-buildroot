#############################################################
#
# LWBx Regulatory Utilities
#
#############################################################
LRU_CYPRESS_VERSION = local
LRU_CYPRESS_SITE = package/lrd-closed-source/externals/lru_cypress
LRU_CYPRESS_SITE_METHOD = local
LRU_CYPRESS_DEPENDENCIES = host-pkgconf libnl libedit
LRU_CYPRESS_MAKE_OPTS = CXX="$(TARGET_CXX)" CC="$(TARGET_CC)" LD="$(TARGET_LD)" LDFLAGS="$(TARGET_LDFLAGS)"
LRU_CYPRESS_MAKE_ENV += $(TARGET_MAKE_ENV) \
	PKG_CONFIG="$(HOST_DIR)/usr/bin/pkg-config" \
	CFLAGS="$(TARGET_CFLAGS)" \
	AR="$(TARGET_AR)"

#
# BUILD
#
ifeq ($(BR2_PACKAGE_LRU_CYPRESS),y)
define LAIRD_LRU_CYPRESS_BUILD_CMDS
	rm -f $(TARGET_DIR)/usr/bin/lru
	$(LRU_CYPRESS_MAKE_ENV) $(MAKE) $(LRU_CYPRESS_MAKE_OPTS) -C $(@D)/lru
endef
endif

define LRU_CYPRESS_BUILD_CMDS
	$(LAIRD_LRU_CYPRESS_BUILD_CMDS)
endef

#
#Install
#
ifeq ($(BR2_PACKAGE_LRU_CYPRESS),y)
define LAIRD_LRU_CYPRESS_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/lru/bin/lru $(TARGET_DIR)/usr/bin/lru
endef
endif

define LRU_CYPRESS_INSTALL_TARGET_CMDS
	$(LAIRD_LRU_CYPRESS_INSTALL_TARGET_CMDS)
endef

#
# Uninstall
#
define LRU_CYPRESS_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/bin/lru
endef

$(eval $(generic-package))
