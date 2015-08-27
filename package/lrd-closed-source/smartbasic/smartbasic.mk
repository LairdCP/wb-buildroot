###############################################################
#
#smartbasic
#
##############################################################


SMARTBASIC_VERSION = local
SMARTBASIC_SITE = $(TOPDIR)/package/lrd-closed-source/externals/smartbasic
SMARTBASIC_SITE_METHOD = local
SMARTBASIC_INSTALL_STAGING = YES

SMARTBASIC_DEPENDENCIES = libbluetopia
SMARTBASIC_MAKE_ENV = CC="$(TARGET_CC)" \
				ARCH=arm \
				CROSS_COMPILE=$(TARGET_CROSS) \

define SMARTBASIC_BUILD_CMDS
	$(SMARTBASIC_MAKE_ENV) $(MAKE) $(LINUX_MAKE_FLAGS) SMARTBASIC_BUILD_ENVIRONMENT=wb -C $(@D)/UwApp/smartSS
endef

define SMARTBASIC_INSTALL_TARGET_CMDS
	mkdir -p -m 700 $(TARGET_DIR)/usr/sbfs
	$(INSTALL) -D -m 755 $(@D)/UwApp/smartSS/DebugLinux/smartBASIC $(TARGET_DIR)/usr/bin/smartBASIC
	$(INSTALL) -D -m 755 $(@D)/UwApp/smartSS/DebugLinux/smartSS $(TARGET_DIR)/usr/bin/smartSS
endef

$(eval $(generic-package))
