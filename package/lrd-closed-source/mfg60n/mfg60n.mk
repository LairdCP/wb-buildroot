#############################################################
#
# 60 Series Manufacturing Utilities
#
#############################################################
MFG60N_VERSION = local
MFG60N_SITE = package/lrd-closed-source/externals/mfg60n
MFG60N_SITE_METHOD = local
MFG60N_DEPENDENCIES = host-pkgconf

MFG60N_MAKE_OPTS = CXX="$(TARGET_CXX)" CC="$(TARGET_CC)" LD="$(TARGET_LD)" LDFLAGS="$(TARGET_LDFLAGS)"

MFG60N_MAKE_ENV += $(TARGET_MAKE_ENV) \
	PKG_CONFIG="$(HOST_DIR)/usr/bin/pkg-config" \
	CFLAGS="$(TARGET_CFLAGS)" \
	AR="$(TARGET_AR)"

#
# BUILD
#
ifeq ($(BR2_PACKAGE_MFG60N_LIBEDIT),y)
	MFG60N_DEPENDENCIES += libedit
	MFG60N_MAKE_OPTS += LIBEDIT="y"
endif

ifeq ($(BR2_PACKAGE_MFG60N_LRT),y)
	MFG60N_DEPENDENCIES += libnl
define LAIRD_MFG60N_LRT_BUILD_CMD
	$(MFG60N_MAKE_ENV) $(MAKE) $(MFG60N_MAKE_OPTS) -C $(@D)/lrt
endef
endif

ifeq ($(BR2_PACKAGE_MFG60N_LMU),y)
	MFG60N_DEPENDENCIES += libnl
define LAIRD_MFG60N_VENDOR_BUILD_LMU_CMD
	$(MFG60N_MAKE_ENV) $(MAKE) $(MFG60N_MAKE_OPTS) -C $(@D)/lmu
endef
endif

ifeq ($(BR2_PACKAGE_MFG60N_LRU),y)
	MFG60N_DEPENDENCIES += libnl
define LAIRD_MFG60N_VENDOR_BUILD_LRU_CMD
	$(MFG60N_MAKE_ENV) $(MAKE) $(MFG60N_MAKE_OPTS) -C $(@D)/lru
endef
endif

ifeq ($(BR2_PACKAGE_MFG60N_BTLRU),y)
ifeq ($(BR2_PACKAGE_BLUEZ_UTILS),y)
	MFG60N_DEPENDENCIES += bluez_utils
else
	MFG60N_DEPENDENCIES += bluez5_utils
endif
define LAIRD_MFG60N_VENDOR_BUILD_BTLRU_CMD
	$(MFG60N_MAKE_ENV) $(MAKE) $(MFG60N_MAKE_OPTS) -C $(@D)/btlru
endef
endif

define MFG60N_BUILD_CMDS
	rm -f $(TARGET_DIR)/usr/bin/lrt
	$(LAIRD_MFG60N_VENDOR_BUILD_LMU_CMD)
	$(LAIRD_MFG60N_VENDOR_BUILD_LRU_CMD)
	$(LAIRD_MFG60N_VENDOR_BUILD_BTLRU_CMD)
	$(LAIRD_MFG60N_LRT_BUILD_CMD)
endef

#
#Install
#
ifeq ($(BR2_PACKAGE_MFG60N_LRT),y)
define LAIRD_MFG60N_LRT_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/lrt/bin/lrt $(TARGET_DIR)/usr/bin/lrt
endef
endif

ifeq ($(BR2_PACKAGE_MFG60N_LMU),y)
define LAIRD_MFG60N_VENDOR_INSTALL_LMU_CMD
	$(INSTALL) -D -m 755 $(@D)/lmu/bin/lmu $(TARGET_DIR)/usr/bin/lmu
endef
endif

ifeq ($(BR2_PACKAGE_MFG60N_LRU),y)
define LAIRD_MFG60N_VENDOR_INSTALL_LRU_CMD
	$(INSTALL) -D -m 755 $(@D)/lru/bin/lru $(TARGET_DIR)/usr/bin/lru
endef
endif

ifeq ($(BR2_PACKAGE_MFG60N_BTLRU),y)
define LAIRD_MFG60N_VENDOR_INSTALL_BTLRU_CMD
	$(INSTALL) -D -m 755 $(@D)/btlru/bin/btlru $(TARGET_DIR)/usr/bin/btlru
endef
endif

define MFG60N_INSTALL_TARGET_CMDS
	$(LAIRD_MFG60N_VENDOR_INSTALL_LMU_CMD)
	$(LAIRD_MFG60N_VENDOR_INSTALL_LRU_CMD)
	$(LAIRD_MFG60N_VENDOR_INSTALL_BTLRU_CMD)
	$(LAIRD_MFG60N_LRT_INSTALL_TARGET_CMDS)
endef

#
# Uninstall
#
define MFG60N_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/bin/lmu
	rm -f $(TARGET_DIR)/usr/bin/lru
	rm -f $(TARGET_DIR)/usr/bin/btlru
	rm -f $(TARGET_DIR)/usr/bin/lrt
endef

$(eval $(generic-package))
