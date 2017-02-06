###############################################################
#
#smartbasic
#
##############################################################


SMARTBASIC_VERSION = local
SMARTBASIC_SITE = $(TOPDIR)/package/lrd-closed-source/externals/smartbasic
SMARTBASIC_SITE_METHOD = local
SMARTBASIC_INSTALL_STAGING = YES


SMARTBASIC_DEPENDENCIES = libbluetopia host-ncurses

SMARTBASIC_MAKE_ENV = CC="$(TARGET_CC)" \
				ARCH=arm \
				CROSS_COMPILE=$(TARGET_CROSS) \

ifeq ($(BR2_LRD_PLATFORM_WB50N),y)
    SMARTBASIC_FLAGS := CONFIG_SMARTBASIC_WB50N=y
else ifeq ($(BR2_LRD_PLATFORM_WB45N),y)
    SMARTBASIC_FLAGS := CONFIG_SMARTBASIC_WB45N=y
else ifeq ($(BR2_PACKAGE_SMARTBASIC),y)
    $(error "ERROR: Expected BR2_LRD_PLATFORM to be wb50n, wb45n.")
endif

define SMARTBASIC_BUILD_CMDS
	$(SMARTBASIC_MAKE_ENV) $(MAKE) $(LINUX_MAKE_FLAGS) SMARTBASIC_BUILD_ENVIRONMENT=wb -C $(@D)/UwApp/smartSS -f smartBASIC-wb.mk $(SMARTBASIC_FLAGS)
endef

define SMARTBASIC_INSTALL_TARGET_CMDS
	mkdir -p -m 700 $(TARGET_DIR)/usr/sbfs
	$(INSTALL) -D -m 755 $(@D)/UwApp/smartSS/DebugLinux/smartBASIC $(TARGET_DIR)/usr/bin/smartBASIC
	$(INSTALL) -D -m 755 $(@D)/UwApp/smartSS/DebugLinux/smartSS $(TARGET_DIR)/usr/bin/smartSS
endef

$(eval $(generic-package))
