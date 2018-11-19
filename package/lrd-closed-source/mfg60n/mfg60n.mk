#############################################################
#
# 60 Series Manufacturing Utilities
#
#############################################################
MFG60N_VERSION = local
MFG60N_SITE = package/lrd-closed-source/externals/mfg60n
MFG60N_SITE_METHOD = local
MFG60N_DEPENDENCIES = host-pkgconf libnl libedit
MFG60N_MAKE_OPTS = CXX="$(TARGET_CXX)" CC="$(TARGET_CC)" LD="$(TARGET_LD)" LDFLAGS="$(TARGET_LDFLAGS)"
MFG60N_MAKE_ENV += $(TARGET_MAKE_ENV) \
	PKG_CONFIG="$(HOST_DIR)/usr/bin/pkg-config" \
	CFLAGS="$(TARGET_CFLAGS)" \
	AR="$(TARGET_AR)"

#
# BUILD
#
ifeq ($(BR2_PACKAGE_MFG60N_VENDOR),y)
define LAIRD_MFG60N_VENDOR_BUILD_CMDS
	rm -f $(TARGET_DIR)/usr/bin/lrt
	$(MFG60N_MAKE_ENV) $(MAKE) $(MFG60N_MAKE_OPTS) -C $(@D)/lmu
	$(MFG60N_MAKE_ENV) $(MAKE) $(MFG60N_MAKE_OPTS) -C $(@D)/lru
	$(MFG60N_MAKE_ENV) $(MAKE) $(MFG60N_MAKE_OPTS) -C $(@D)/btlru
	$(MFG60N_MAKE_ENV) $(MAKE) $(MFG60N_MAKE_OPTS) -C $(@D)/wow
endef
endif

ifeq ($(BR2_PACKAGE_MFG60N_LRT),y)
define LAIRD_MFG60N_LRT_BUILD_CMDS
	$(MFG60N_MAKE_ENV) $(MAKE) $(MFG60N_MAKE_OPTS) -C $(@D)/lrt
endef
endif

define MFG60N_BUILD_CMDS
	$(LAIRD_MFG60N_VENDOR_BUILD_CMDS)
	$(LAIRD_MFG60N_LRT_BUILD_CMDS)
endef

#
#Install
#
ifeq ($(BR2_PACKAGE_MFG60N_VENDOR),y)
define LAIRD_MFG60N_VENDOR_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/lru/bin/lru $(TARGET_DIR)/usr/bin/lru
	$(INSTALL) -D -m 755 $(@D)/btlru/bin/btlru $(TARGET_DIR)/usr/bin/btlru
	$(INSTALL) -D -m 755 $(@D)/lmu/bin/lmu $(TARGET_DIR)/usr/bin/lmu
endef
endif

ifeq ($(BR2_PACKAGE_MFG60N_LRT),y)
define LAIRD_MFG60N_LRT_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/lrt/bin/lrt $(TARGET_DIR)/usr/bin/lrt
endef
endif

define MFG60N_INSTALL_TARGET_CMDS
	$(LAIRD_MFG60N_VENDOR_INSTALL_TARGET_CMDS)
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
