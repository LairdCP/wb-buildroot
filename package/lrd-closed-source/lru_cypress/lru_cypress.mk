#############################################################
#
# LWBx Regulatory Utilities
#
#############################################################
LRU_CYPRESS_VERSION = local
LRU_CYPRESS_SITE = package/lrd-closed-source/externals/lru_cypress
LRU_CYPRESS_SITE_METHOD = local
LRU_CYPRESS_DEPENDENCIES = host-pkgconf libnl libedit

ifeq ($(BR2_PACKAGE_BLUEZ_UTILS),y)
LRU_CYPRESS_DEPENDENCIES += bluez_utils
else
LRU_CYPRESS_DEPENDENCIES += bluez5_utils
endif

define LRU_CYPRESS_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)/lru
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)/btlru
endef

define LRU_CYPRESS_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/lru/bin/lru $(TARGET_DIR)/usr/bin/lru
	$(INSTALL) -D -m 755 $(@D)/btlru/bin/btlru $(TARGET_DIR)/usr/bin/btlru
endef

define LRU_CYPRESS_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/bin/lru
	rm -f $(TARGET_DIR)/usr/bin/btlru
endef

$(eval $(generic-package))
