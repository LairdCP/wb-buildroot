#############################################################
#
# Laird Event Monitor
#
#############################################################

EVENTMON_VERSION = local
EVENTMON_SITE = package/lrd/externals/eventmon
EVENTMON_SITE_METHOD = local

ifeq ($(BR2_PACKAGE_WB_LEGACY_SUMMIT_SUPPLICANT_BINARIES),y)
EVENTMON_DEPENDENCIES = wb-legacy-summit-supplicant-binaries
else
EVENTMON_DEPENDENCIES = sdcsdk
endif

EVENTMON_MAKE_ENV = CC="$(TARGET_CC)" \
                    CXX="$(TARGET_CXX)" \
                    ARCH="$(KERNEL_ARCH)" \
                    CFLAGS="$(TARGET_CFLAGS)"

define EVENTMON_BUILD_CMDS
    $(MAKE) -C $(@D) clean
	$(EVENTMON_MAKE_ENV) $(MAKE) -C $(@D)
endef

define EVENTMON_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/event_mon $(TARGET_DIR)/usr/bin/event_mon
endef

define EVENTMON_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/bin/event_mon
endef

$(eval $(generic-package))
